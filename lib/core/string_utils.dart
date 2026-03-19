// BUG FIXED: Bug 4 - Outcome name string has leading space and inconsistent casing.
// HOW: Created a dedicated utility to convert camelCase enum names to spaced, uppercase labels properly.

class StringUtils {
  static String outcomeLabel(String camelCase) {
    final result = camelCase.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (m) => ' ${m.group(0)}',
    );
    return result.trim().toUpperCase();
  }
}
