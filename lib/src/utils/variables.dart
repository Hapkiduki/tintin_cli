import 'package:yaml/yaml.dart';

class Variable {
  const Variable({
    required this.name,
    required this.type,
    required this.description,
    required this.prompt,
  });
  final String name;
  final String type;
  final String description;
  final String prompt;

  static List<Variable> fromYaml(String yamlContent) {
    final yamlMap = loadYaml(yamlContent) as YamlMap;

    final vars = (yamlMap['vars'] as YamlMap?) ?? YamlMap();

    return vars.entries.map(
      (e) {
        final varData = e.value as YamlMap;
        return Variable(
          name: e.key as String,
          type: varData['type'] as String,
          description: varData['description'] as String,
          prompt: varData['prompt'] as String,
        );
      },
    ).toList();
  }
}
