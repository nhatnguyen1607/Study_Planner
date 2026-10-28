import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

void main() {
  for (final labels in [
    ['6h', '9h', '12h', '15h', '18h', '21h', '24h'],
    ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
  ]) {
    testWidgets('Chart keeps ${labels.first} axis labels clear of bars', (
      tester,
    ) async {
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: boundaryKey,
                child: ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    width: 350,
                    child: KChart(const [1, 2, 1.5, 3, 4, 2.5, 1.8], labels),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final plot = find.descendant(
        of: find.byType(KChart),
        matching: find.byType(CustomPaint),
      );
      final plotBottom = tester.getBottomLeft(plot).dy;
      for (final label in labels) {
        expect(
          tester.getTopLeft(find.text(label)).dy,
          greaterThanOrEqualTo(plotBottom + 8),
        );
      }
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final (image, pixels) = (await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final pixels = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        return (image, pixels);
      }))!;
      // No rounded bar end may paint into the gap above the labels.
      for (var y = 150; y < 158; y++) {
        for (var x = 0; x < image.width; x++) {
          final offset = (y * image.width + x) * 4;
          expect(pixels.getUint8(offset), 255);
          expect(pixels.getUint8(offset + 1), 255);
          expect(pixels.getUint8(offset + 2), 255);
        }
      }
      image.dispose();
      expect(tester.takeException(), isNull);
    });
  }
}
