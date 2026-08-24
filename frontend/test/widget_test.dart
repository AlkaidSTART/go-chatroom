import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('renders chat page and sends a message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChatApp());

    expect(find.text('进入聊天室'), findsOneWidget);
    await tester.tap(find.text('进入聊天室'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('微光聊天室'), findsOneWidget);
    expect(find.text('输入消息'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '你好，气泡真轻');
    await tester.tap(find.byTooltip('发送'));
    await tester.pump();

    expect(find.text('你好，气泡真轻'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('收到，这个节奏很稳。'), findsOneWidget);

    await tester.tap(find.text('退出'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('进入聊天室'), findsOneWidget);
  });
}
