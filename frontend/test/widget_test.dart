import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/chat_page.dart';
import 'package:frontend/chat_socket.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('opens chat page and exits to home', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatApp());

    expect(find.text('进入聊天室'), findsOneWidget);
    await tester.tap(find.text('进入聊天室'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('微光聊天室'), findsOneWidget);
    expect(find.text('输入消息'), findsOneWidget);

    await tester.tap(find.text('退出'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('进入聊天室'), findsOneWidget);
  });

  testWidgets('sends and receives real socket messages', (
    WidgetTester tester,
  ) async {
    final socket = _FakeChatSocket();
    await tester.pumpWidget(
      MaterialApp(home: ChatPage(channelFactory: (_) => socket)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('后端已连接'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '你好，这是真实消息');
    await tester.tap(find.byTooltip('发送'));
    await tester.pump();

    expect(find.text('你好，这是真实消息'), findsOneWidget);
    expect(socket.sent, hasLength(1));
    final decoded =
        jsonDecode(socket.sent.single as String) as Map<String, dynamic>;
    expect(decoded['text'], '你好，这是真实消息');

    socket.receive('{"clientId":"other","sender":"新朋友","text":"真实回包"}');
    await tester.pump();
    expect(find.text('真实回包'), findsOneWidget);
    expect(find.text('新朋友'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _FakeChatSocket implements ChatSocket {
  _FakeChatSocket() {
    _outgoing.stream.listen(sent.add);
  }

  final List<dynamic> sent = [];
  final StreamController<dynamic> _incoming = StreamController<dynamic>();
  final StreamController<dynamic> _outgoing = StreamController<dynamic>();
  bool _closed = false;

  @override
  Stream<dynamic> get stream => _incoming.stream;

  @override
  StreamSink<dynamic> get sink => _outgoing.sink;

  @override
  Future<void> get ready => Future.value();

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    await _incoming.close();
    await _outgoing.close();
  }

  void receive(String message) {
    _incoming.add(message);
  }
}
