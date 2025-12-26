import "package:flutter_test/flutter_test.dart";
import "package:petalpost/shared/utils/string_utils.dart";

void main() {
  test("truncate short strings unchanged", () {
    expect(StringUtils.truncate("hello", 10), "hello");
  });

  test("truncate long strings adds ellipsis", () {
    expect(StringUtils.truncate("hello world", 5), "hello...");
  });
}
