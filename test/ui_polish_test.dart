import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csc_4330_hobby_app/app.dart';
import 'package:csc_4330_hobby_app/core/app_theme.dart';
import 'package:csc_4330_hobby_app/data/models.dart';
import 'package:csc_4330_hobby_app/features/hobbies/hobby_catalog.dart';
import 'package:csc_4330_hobby_app/features/hobbies/hobby_detail_page.dart';
import 'package:csc_4330_hobby_app/features/listings/listing_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {'Fraunces': 'Fraunces', 'DM Sans': 'DMSans'}.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load('assets/fonts/${entry.value}.ttf'));
      await loader.load();
    }
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  testWidgets('Branded Home fits a narrow phone with bundled fonts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: key, child: const HobbySwapApp()),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(AppTheme.light.textTheme.headlineLarge?.fontFamily, 'Fraunces');
    expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, 'DM Sans');
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final screenshot = await boundary.toImage();
      final bytes = await screenshot.toByteData(format: ui.ImageByteFormat.png);
      await Directory('build/ui-preview').create(recursive: true);
      await File('build/ui-preview/home.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      screenshot.dispose();
    });
  });

  testWidgets('Starter progress follows checked supplies', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HobbyDetailPage(
          hobby: hobbyCatalog.first,
          checkedItems: <String>{},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0,
    );
    await tester.ensureVisible(find.text('Watercolor paints'));
    await tester.tap(find.text('Watercolor paints'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      .2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Offer badges identify both types using labels and icons', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            children: [
              ListingBadge(type: ListingType.swap),
              ListingBadge(type: ListingType.giveaway),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Swap'), findsOneWidget);
    expect(find.text('Giveaway'), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    expect(find.byIcon(Icons.volunteer_activism_outlined), findsOneWidget);
  });
}
