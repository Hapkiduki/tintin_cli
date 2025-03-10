import 'dart:io';
import 'package:args/args.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final env = DotEnv()..load();
  final argParser = ArgParser();

  final generateCommand = argParser.addCommand('generate');
  generateCommand.addOption('description',
      abbr: 'd', help: 'Descripción de la función a generar');

  try {
    final ArgResults results = argParser.parse(arguments);

    if (results.command?.name == 'generate') {
      final description = results.command?['description'] as String?;
      if (description == null) {
        print('Proporcione una descripción con -d o --description');
        exit(1);
      }

      final apiKey = env['OPENAI_API_KEY'];
      if (apiKey == null) {
        print('Configure la variable de entorno OPENAI_API_KEY');
        exit(1);
      }

      final brickJson = await generateBrickwithAI(apiKey, description);

      final tempDir = Directory.systemTemp.createTempSync('mason_brick_');
      final brickDir = Directory(path.join(tempDir.path, 'brick'));
      brickDir.createSync();

      // Corrección: Solo escribe brick.yaml
      final brickYaml = brickJson['brick.yaml'] as String;
      File(path.join(brickDir.path, 'brick.yaml')).writeAsStringSync(brickYaml);

      final templateFiles = brickJson['template_files'] as Map<String, dynamic>;
      templateFiles.forEach((filePath, content) {
        final fullPath = path.join(brickDir.path, '__brick__', filePath);
        final file = File(fullPath);
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(content as String);
      });

      // Corrección: Obtener variables necesarias
      final logger = Logger();
      final featureName = logger.prompt('¿Nombre de la función?');

      final mason = await MasonGenerator.fromBrick(Brick.path(brickDir.path));
      final target = DirectoryGeneratorTarget(Directory.current);

      // Corrección: Pasar variables al generar
      await mason.generate(
        target,
        vars: {'feature_name': featureName},
      );

      print('Función generada en ${target.dir.path}');
    } else {
      print('Comando desconocido');
      exit(1);
    }
  } on FormatException catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<Map<String, dynamic>> generateBrickwithAI(
    String apiKey, String description) async {
  // Corrección: Usar 'brick.yaml' como clave
  return {
    'brick.yaml': '''
name: generated_feature
description: Función generada por tintin_cli
version: 0.0.1
environment:
  mason: ">=0.1.0-dev.57 <0.1.0"
vars:
  feature_name:
    type: string
    description: Nombre de la función
    prompt: ¿Nombre de la función?
''',
    'template_files': {
      '{{feature_name}}/{{feature_name}}.dart': '''
import 'package:flutter/material.dart';

class {{feature_name.pascalCase()}} extends StatelessWidget { 
  const {{feature_name.pascalCase()}}({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{feature_name}}')
      ),
      body: const Center(
        child: Text('Función generada por IA'),
      ),
    );
  }
}
'''
    }
  };
}
