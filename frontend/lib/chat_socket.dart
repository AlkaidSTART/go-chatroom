import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Thin socket abstraction so the chat page can be tested with a fake peer.
abstract interface class ChatSocket {
  Stream<dynamic> get stream;
  StreamSink<dynamic> get sink;
  Future<void> get ready;
  Future<void> close();
}

class WebSocketChatSocket implements ChatSocket {
  WebSocketChatSocket(this._channel);

  final WebSocketChannel _channel;

  @override
  Stream<dynamic> get stream => _channel.stream;

  @override
  StreamSink<dynamic> get sink => _channel.sink;

  @override
  Future<void> get ready => _channel.ready;

  @override
  Future<void> close() => _channel.sink.close();
}
