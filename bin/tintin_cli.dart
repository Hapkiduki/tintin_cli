import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:tintin_cli/src/commands/generate_command.dart';

void main(List<String> arguments) async {
  final logger = Logger();
  final runner = CommandRunner<void>(
    'tintin',
    'A professional Flutter code generator with AI capabilities',
  )
    ..addCommand(GenerateCommand(logger: logger))
    ..argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Enable verbose logging',
      negatable: false,
    );

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    logger.err(e.message);
    exit(64); // EX_USAGE exit code
  } catch (e, stackTrace) {
    logger.err('An unexpected error occurred: $e');
    if (arguments.contains('--verbose')) logger.detail(stackTrace.toString());
    exit(1);
  }
}
