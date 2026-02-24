// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smartnote/main.dart';

void main() {
  testWidgets('Smart Note home screen loads', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const SmartNoteApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Smart Note -'), findsOneWidget);
    expect(find.text('Bạn chưa có ghi chú nào, hãy tạo mới nhé!'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
