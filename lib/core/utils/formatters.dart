
class Formatters {
  Formatters._();

  // Formats a number with thousand separators.
  // Example: 6000 -> '6,000'
  static String formatNumber(double value) {
    final digits = value.toStringAsFixed(0);
    return digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}
