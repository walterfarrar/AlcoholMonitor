class AlcoholCalculator {
  /// 1 US standard drink = 0.6 fl oz of pure alcohol
  static const double _pureAlcoholPerStandardDrink = 0.6;

  /// Converts a volume of beverage at a given ABV% into standard drinks.
  static double calculateStandardDrinks({
    required double volumeOz,
    required double abvPercent,
  }) {
    final pureAlcoholOz = volumeOz * (abvPercent / 100.0);
    return pureAlcoholOz / _pureAlcoholPerStandardDrink;
  }

  static double cupsToOz(double cups) => cups * 8.0;
}
