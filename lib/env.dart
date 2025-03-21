import 'package:envied/envied.dart';

part '../env.g.dart';

@Envied(requireEnvFile: true)
abstract class Env {
  @EnviedField(varName: 'OPENAI_API_KEY')
  static const String openaiApiKey = _Env.openaiApiKey;
}
