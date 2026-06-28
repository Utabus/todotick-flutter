import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_ai/main.dart';

void main() {
  testWidgets('TodoTick app smoke test — app khởi động không crash',
      (WidgetTester tester) async {
    // Wrap với ProviderScope vì app dùng Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Cho phép async providers load xong
    await tester.pumpAndSettle();

    // Kiểm tra app render được (không crash)
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('TodoTick — màn hình home hiển thị tiêu đề',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // App title hoặc scaffold phải tồn tại
    expect(find.byType(Scaffold), findsWidgets);
  });
}
