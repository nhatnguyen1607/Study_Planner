import 'dart:io';

import 'package:study_planner_flutter/services/gemini_client.dart';
import 'package:study_planner_flutter/model/generated_study_plan.dart';

Future<void> main(List<String> arguments) async {
  final values = <String, String>{};
  if (await File('.env').exists()) {
    for (final line in await File('.env').readAsLines()) {
      final match = RegExp(
        r'^\s*(?:export\s+)?([A-Z][A-Z0-9_]*)\s*=\s*(.*?)\s*$',
      ).firstMatch(line);
      if (match == null) continue;
      var value = match.group(2)!;
      if (value.length >= 2 &&
          ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'")))) {
        value = value.substring(1, value.length - 1);
      }
      values[match.group(1)!] = value;
    }
  }
  final requested = arguments
      .where((a) => a.startsWith('--model='))
      .firstOrNull;
  final client = GeminiClient(
    apiKey:
        Platform.environment['GEMINI_API_KEY'] ??
        values['GEMINI_API_KEY'] ??
        '',
    model:
        requested?.substring('--model='.length) ??
        values['GEMINI_MODEL'] ??
        'gemini-3.5-flash-lite',
  );
  try {
    final plan = await client.generate(
      ['Toán', 'Tiếng Anh'],
      2,
      objective: 'Ôn lại kiến thức cơ bản trong tuần.',
    );
    stdout.writeln(
      'Gemini OK: validated ${plan.sessions.length} sessions, ${plan.weeklyMinutes}/120 minutes. No Firestore writes.',
    );
  } on GeminiFailure catch (e) {
    stderr.writeln(e.toString());
    exitCode = 1;
  } catch (_) {
    stderr.writeln('Smoke test failed; no credentials or raw response logged.');
    exitCode = 1;
  } finally {
    client.close();
  }
}
