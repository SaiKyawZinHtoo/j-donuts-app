import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

/// Writes one `<reportKey>.timeline_summary.json` per traced segment to
/// build/ (frame build/raster times and missed-budget counts).
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) return;
    for (final entry in data.entries) {
      final timeline = driver.Timeline.fromJson(
        entry.value as Map<String, dynamic>,
      );
      await driver.TimelineSummary.summarize(
        timeline,
      ).writeTimelineToFile(entry.key, pretty: true, includeSummary: true);
    }
  },
);
