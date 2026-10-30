/// Helpers for reading numbers typed on Arabic or English keyboards.
class Parsing {
  Parsing._();

  static const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';

  /// 3-20 characters: Latin letters, digits, dot, dash or underscore. It must
  /// start and end with a letter or digit and cannot contain "..", because the
  /// username becomes the local part of Firebase's internal e-mail address.
  static final RegExp usernameRegex =
      RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]{1,18}[a-zA-Z0-9]$');

  static bool isValidUsername(String? input) {
    final value = (input ?? '').trim();
    return usernameRegex.hasMatch(value) && !value.contains('..');
  }

  /// Converts Arabic-Indic digits and Arabic/European decimal separators to
  /// plain ASCII so that "٧٥٫٥" and "75,5" both become "75.5".
  static String normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      final index = _arabicIndicDigits.indexOf(ch);
      if (index >= 0) {
        buffer.write(index);
      } else if (ch == '٫' || ch == ',' || ch == '،') {
        buffer.write('.');
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString().trim();
  }

  static double? toDouble(String? input) {
    if (input == null) return null;
    final normalized = normalizeDigits(input);
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  static int? toInt(String? input) {
    if (input == null) return null;
    final normalized = normalizeDigits(input);
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }
}
