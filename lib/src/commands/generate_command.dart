import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:tintin_cli/src/utils/ai_service.dart';
import 'package:tintin_cli/src/utils/variables.dart';

class GenerateCommand extends Command<void> {
  GenerateCommand({required this.logger}) {
    argParser
      ..addOption(
        'description',
        abbr: 'd',
        help: 'Feature description for AI generation',
        mandatory: true,
      )
      ..addFlag(
        'dry-run',
        help: 'Preview generation without writing files',
        negatable: false,
      );
  }
  final Logger logger;

  @override
  String get name => 'generate';
  @override
  String get description => 'Generate Flutter features using AI';

  @override
  Future<void> run() async {
    final description = argResults?['description'] as String;
    final dryRun = argResults?['dry-run'] as bool;

    try {
      final brickJson = await AIService.generateBrick(description);
      //final brickJson = await AIService.generateBrickMock(description);
      await _processBrickGeneration(brickJson, dryRun: dryRun);
    } catch (e) {
      logger.err('Generation failed: $e');
      exit(1);
    }
  }

  Future<void> _processBrickGeneration(
    Map<String, dynamic> brickJson, {
    required bool dryRun,
  }) async {
    final tempDir = Directory.systemTemp.createTempSync('mason_brick_');
    final brickDir = Directory(path.join(tempDir.path, 'brick'))
      ..createSync(recursive: true);

    final vars = await _writeBrickConfig(brickJson, brickDir);
    await _writeTemplateFiles(brickJson, brickDir);

    final generator = await MasonGenerator.fromBrick(
      Brick.path(brickDir.path),
    );

    final target = DirectoryGeneratorTarget(Directory.current);

    logger.info(dryRun ? 'Dry run results:' : 'Generating feature...');
    await _runHooks(generator, vars, dryRun: dryRun);

    final results = await generator.generate(
      target,
      vars: vars,
      fileConflictResolution: FileConflictResolution.overwrite,
    );

    _displayGenerationResults(results, dryRun: dryRun);
  }

  Future<void> _runHooks(
    MasonGenerator generator,
    Map<String, dynamic> vars, {
    required bool dryRun,
  }) async {
    if (!dryRun) {
      await generator.hooks.preGen(
        vars: vars,
        onVarsChanged: (updatedVars) => vars.addAll(updatedVars),
      );
    }
  }

  Future<Map<String, dynamic>> _writeBrickConfig(
    Map<String, dynamic> brickJson,
    Directory brickDir,
  ) {
    final configContent = brickJson['brick.yaml'] as String;
    File(path.join(brickDir.path, 'brick.yaml'))
      ..createSync(recursive: true)
      ..writeAsStringSync(configContent);
    final variables = Variable.fromYaml(configContent);
    return _collectVariables(variables);
  }

  Future<void> _writeTemplateFiles(
    Map<String, dynamic> brickJson,
    Directory brickDir,
  ) async {
    final templateFiles = brickJson['template_files'] as Map<String, dynamic>;
    for (final entry in templateFiles.entries) {
      final filePath = path.join(brickDir.path, '__brick__', entry.key);
      final content = entry.value as String;
      await File(filePath)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(content);
    }
  }

  Future<Map<String, dynamic>> _collectVariables(
    List<Variable> variables,
  ) async {
    final vars = <String, dynamic>{};
    for (final variable in variables) {
      vars[variable.name] = await _promptVariable(variable);
    }
    return vars;
  }

  Future<dynamic> _promptVariable(Variable variable) async {
    logger.info(variable.description);
    return logger.prompt(
      '${variable.prompt} (${variable.type})',
    );
  }

  void _displayGenerationResults(
    List<GeneratedFile> results, {
    required bool dryRun,
  }) {
    if (dryRun) {
      logger.info('\nWould create:');
    } else {
      logger.success('\nSuccessfully generated:');
    }

    for (final file in results) {
      logger.info('  ${file.path}');
    }

    logger.info(
        '\n${results.length} files ${dryRun ? 'would be' : 'were'} generated');
  }
}
