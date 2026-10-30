/// Small number formatting helpers shared by several screens.
class Format {
  Format._();

  /// 72.5 -> "72.5"
  static String kg(double value) => value.toStringAsFixed(1);

  /// Signed change with one decimal: -1.2 -> "−1.2", 0.8 -> "+0.8", 0 -> "0.0".
  static String signedKg(double value) {
    final rounded = (value * 10).round() / 10;
    if (rounded == 0) return '0.0';
    final sign = rounded > 0 ? '+' : '−';
    return '$sign${rounded.abs().toStringAsFixed(1)}';
  }
}
