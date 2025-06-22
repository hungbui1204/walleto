import 'android_studio/gen_android_studio.dart';
import 'common/index.dart';

void main() {
  final Map<FlavorsEnum, Map<String, String>> allDartDefinesByEnv = {};

  for (var element in flavorsList) {
    allDartDefinesByEnv[element.flavorEnum] = readDartDefineFromEnv(element.envPath, element.name);
  }

  AndroidStudioEnvGenerator(allDartDefinesByEnv: allDartDefinesByEnv).call();
}
