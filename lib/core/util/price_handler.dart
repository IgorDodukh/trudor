import 'dart:math';

class NumberHandler {
  static double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  static String formatPrice(num number) {
    if (number == number.toInt().toDouble()) {
      return number.toInt().toString();
    } else {
      return number.toStringAsFixed(2);
    }
  }

  static String compactPrice(num number) {
    final String price;
    if (number >= 1000 && number < 1000000) {
      price = '${(number / 1000).toStringAsFixed(0)}K';
    } else if (number >= 1000000 && number < 1000000000) {
      price = '${(number / 1000000).toStringAsFixed(0)}M';
    } else if (number >= 1000000000) {
      price = '${(number / 1000000000).toStringAsFixed(0)}B';
    } else {
      price = number.toStringAsFixed(2);
    }
    return price;
  }
}
