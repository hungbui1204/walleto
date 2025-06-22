enum FlavorsEnum { development, staging, production }

class Flavor {
  const Flavor({
    required this.flavorEnum,
    required this.name,
    required this.prefix,
    required this.envPath,
  });

  final FlavorsEnum flavorEnum;
  final String name;
  final String prefix;
  final String envPath;

  bool isEqualToString(String value) {
    final String formattedValue = value.toLowerCase().trim();
    return formattedValue.contains(name.toLowerCase().trim()) ||
        formattedValue.contains(prefix.toLowerCase().trim());
  }
}
