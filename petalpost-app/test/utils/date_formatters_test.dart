import "package:flutter_test/flutter_test.dart";
import "package:petalpost/shared/utils/date_formatters.dart";

void main() {
  test("daysTogether counts inclusive days", () {
    final start = DateTime(2024, 1, 1);
    final now = DateTime(2024, 1, 1);
    expect(DateFormatters.daysTogether(start, now), 1);
  });

  test("nextMilestoneDays returns positive diff", () {
    final start = DateTime(2024, 1, 1);
    final now = DateTime(2024, 1, 10);
    final next = DateFormatters.nextMilestoneDays(start, now);
    expect(next > 0, true);
  });
}
