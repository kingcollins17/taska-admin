extension NairaFormatter on num {
  /// Formats a number to a comma-separated Naira string with the Naira symbol `₦`.
  ///
  /// Examples:
  /// - `1000.toNaira()` -> `"₦1,000"`
  /// - `94127.toNaira()` -> `"₦94,127"`
  /// - `20010.50.toNaira()` -> `"₦20,010.50"`
  String toNaira({bool showDecimal = false}) {
    final value = this;
    final isNegative = value < 0;
    final absVal = value.abs();

    String formattedStr;
    if (showDecimal || (absVal is double && absVal % 1 != 0)) {
      formattedStr = absVal.toStringAsFixed(2);
    } else {
      formattedStr = absVal.toInt().toString();
    }

    final parts = formattedStr.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : null;

    final buffer = StringBuffer();
    final length = integerPart.length;

    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
    }

    final formattedInteger = buffer.toString();
    final result = decimalPart != null ? '₦$formattedInteger.$decimalPart' : '₦$formattedInteger';

    return isNegative ? '-$result' : result;
  }
}
