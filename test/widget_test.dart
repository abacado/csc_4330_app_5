import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csc_4330_hobby_app/app.dart';

void main() {
  testWidgets('All main destinations are reachable', (tester) async {
    await tester.pumpWidget(const HobbySwapApp());
    expect(find.text('A new hobby starts here.'), findsOneWidget);
    for (final label in ['Explore', 'Post', 'Messages', 'Profile', 'Home']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text('A new hobby starts here.'), findsOneWidget);
  });
}
