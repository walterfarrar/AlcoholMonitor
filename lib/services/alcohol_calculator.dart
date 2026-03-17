class AlcoholCalculator {
  /// 1 US standard drink = 0.6 fl oz of pure alcohol
  static const double pureAlcoholPerStandardDrink = 0.6;
  static const double ozPerMl = 29.5735;

  /// Converts a volume of beverage at a given ABV% into standard drinks.
  static double calculateStandardDrinks({
    required double volumeOz,
    required double abvPercent,
  }) {
    final pureAlcoholOz = volumeOz * (abvPercent / 100.0);
    return pureAlcoholOz / pureAlcoholPerStandardDrink;
  }

  /// Converts standard drinks to fl oz of a beverage at a given ABV%.
  static double stdDrinksToOz(double stdDrinks, double abvPercent) {
    if (abvPercent <= 0) return 0;
    return stdDrinks * pureAlcoholPerStandardDrink / (abvPercent / 100.0);
  }

  /// Converts standard drinks to mL of a beverage at a given ABV%.
  static double stdDrinksToMl(double stdDrinks, double abvPercent) {
    return stdDrinksToOz(stdDrinks, abvPercent) * ozPerMl;
  }

  /// Converts standard drinks to cups of a beverage at a given ABV%.
  static double stdDrinksToCups(double stdDrinks, double abvPercent) {
    return stdDrinksToOz(stdDrinks, abvPercent) / 8.0;
  }

  static double cupsToOz(double cups) => cups * 8.0;
}
