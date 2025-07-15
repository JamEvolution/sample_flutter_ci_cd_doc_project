enum Flavor {
  dev,
  prod,
  staging,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Dev-Sample-App';
      case Flavor.prod:
        return 'Prod-Sample-App';
      case Flavor.staging:
        return 'Staging-Sample-App';
    }
  }

}
