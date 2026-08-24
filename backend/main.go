package main

import (
	"fmt"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type client struct {
	conn *websocket.Conn
	send chan []byte
}

type hub struct {
	mu      sync.Mutex
	clients map[*client]bool
}

var chatHub = &hub{clients: make(map[*client]bool)}

func (h *hub) register(c *client) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.clients[c] = true
}

func (h *hub) unregister(c *client) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if h.clients[c] {
		delete(h.clients, c)
		close(c.send)
	}
}

func (h *hub) broadcast(message []byte) {
	h.mu.Lock()
	defer h.mu.Unlock()
	for c := range h.clients {
		select {
		case c.send <- message:
		default:
		}
	}
}

func (c *client) writePump() {
	for message := range c.send {
		if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
			return
		}
	}
}

func wsHandler(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	c := &client{
		conn: conn,
		send: make(chan []byte, 32),
	}
	chatHub.register(c)
	go c.writePump()
	defer func() {
		chatHub.unregister(c)
		conn.Close()
	}()
	fmt.Println("Client connected")

	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			fmt.Println("Client disconnected")
			return
		}
		fmt.Printf("Message received: %s\n", message)
		chatHub.broadcast(message)
	}
}

func main() {
	http.HandleFunc("/ws", wsHandler)
	fmt.Println("Chatroom backend listening on :8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Println("Error starting server:", err)
	}
}
