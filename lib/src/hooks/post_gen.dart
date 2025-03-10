import 'package:mason/mason.dart';

void run(HookContext context) {
  final logger = context.logger;
  final featureName = context.vars['feature_name'] as String;

  logger
    ..info('Running post-generation tasks...')
    ..success('Feature "$featureName" generated successfully!')
    ..info('Next steps:')
    ..info('1. Add the feature to your app navigation')
    ..info('2. Update dependencies if needed')
    ..info('3. Run flutter pub get');
}
