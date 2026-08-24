# syntax=docker/dockerfile:1

FROM golang:1.26-alpine AS builder
WORKDIR /src

# go.sum may not exist until dependencies are added.
COPY go.mod go.sum* ./
RUN go mod download

COPY . .
# Expects the main package at the backend module root.
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/chatroom-server .

FROM alpine:3.21
RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /out/chatroom-server /usr/local/bin/chatroom-server
EXPOSE 8080
ENTRYPOINT ["chatroom-server"]
