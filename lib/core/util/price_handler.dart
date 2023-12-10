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
}
