import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:tintin_cli/env.dart';

class AIService {
  static Future<Map<String, dynamic>> generateBrick(String description) async {
    final client = OpenAIClient(apiKey: Env.openaiApiKey);
    final res = await client.createChatCompletion(
      request: CreateChatCompletionRequest(
        responseFormat: const ChatCompletionResponseFormat(
          type: ChatCompletionResponseFormatType.jsonObject,
        ),
        model: const ChatCompletionModel.model(ChatCompletionModels.gpt4oMini),
        temperature: 0,
        messages: [
          ChatCompletionMessage.user(
            content: ChatCompletionUserMessageContent.string(
              "Eres experto en Flutter y Mason. Genera un ladrillo Mason para $description usando ESTE FORMATO EXACTO (usa variables como \"{{feature_name}}\" y directorios lib/features/):\n\n{\n  'brick.yaml': 'contenido YAML con vars: feature_name...',\\n  'template_files': {\\n    'ruta/{{var}}.dart': 'código usando {{var.pascalCase()}}...'\n}\n\nIncluye en brick.yaml: vars con prompt para feature_name. En template_files usa snakeCase()/pascalCase(). Solo JSON válido, sin comentarios ni markdown. Este es un ejemplo del brick.yaml:\\nname: generated_feature\\ndescription: Feature generated by AI\\nversion: 0.1.0\\nenvironment:\\n  mason: \">=0.1.0-dev.57 <0.1.0\"\\nvars:\\n  feature_name:\\n    type: string\\n    description: Name of the feature\\n    prompt: What's the feature name?",
            ),
          ),
        ],
      ),
    );
    client.endSession();
    final response =
        jsonDecode(res.choices.first.message.content!) as Map<String, dynamic>;
    print(response);
    return response;
  }

  // Mock version for testing
  static Future<Map<String, dynamic>> generateBrickMock(
    String description,
  ) async {
    return {
      'brick.yaml': '''
name: generated_feature
description: Feature generated by AI
version: 0.1.0
environment:
  mason: ">=0.1.0-dev.57 <0.1.0"
vars:
  feature_name:
    type: string
    description: Name of the feature
    prompt: What's the feature name?
''',
      'template_files': {
        'lib/features/{{feature_name.snakeCase()}}/{{feature_name.snakeCase()}}.dart':
            '''
import 'package:flutter/material.dart';

class {{feature_name.pascalCase()}} extends StatelessWidget {
  const {{feature_name.pascalCase()}}({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
      },
    };
  }
}
