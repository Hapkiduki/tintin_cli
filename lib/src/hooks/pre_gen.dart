import 'package:mason/mason.dart';

void run(HookContext context) {
  final logger = context.logger;
  final featureName = context.vars['feature_name'] as String?;

  logger.info('Validating feature name...');

  if (featureName == null || featureName.isEmpty) {
    throw const MasonException('Feature name is required');
  }

  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(featureName)) {
    throw const MasonException(
      'Invalid feature name: Must be snake_case and start with lowercase letter',
    );
  }

  context.vars = {...context.vars, 'feature_name': featureName};
  logger.success('Validation passed!');
}
