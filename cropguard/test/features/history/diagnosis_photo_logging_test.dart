import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/core/widgets/crop_visual.dart';
import 'package:kroppi/features/history/presentation/widgets/diagnosis_photo.dart';

void main() {
  testWidgets('failed photo keeps its fallback without logging a signed URL', (
    tester,
  ) async {
    const sentinel = 'SYNTHETIC_PRIVATE_DATA';
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };
    try {
      // Flutter's test HTTP client returns 400; no external request is sent.
      await tester.pumpWidget(
        MaterialApp(
          home: DiagnosisPhoto(
            imageUrl: 'https://example.invalid/photo?token=$sentinel',
            cropId: 'cafe',
            width: 100,
            height: 100,
            borderRadius: BorderRadius.circular(8),
            iconSize: 24,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CropVisual), findsOneWidget);
      expect(logs.join('\n'), isNot(contains(sentinel)));
      expect(tester.takeException(), isNull);
    } finally {
      debugPrint = original;
    }
  });
}
