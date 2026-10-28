import 'package:flutter/material.dart';

import '../../viewmodel/study_data_view_model.dart';
import 'auth_scope.dart';

class StudyDatabaseGate extends StatelessWidget {
  const StudyDatabaseGate({super.key, required this.data, required this.child});
  final StudyDataViewModel data;
  final Widget child;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: data,
    builder: (context, _) {
      if (!data.ready || data.errors.isNotEmpty) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data.errors.isEmpty)
                      const CircularProgressIndicator()
                    else ...[
                      const Icon(Icons.cloud_off_outlined, size: 48),
                      const SizedBox(height: 16),
                      Text(data.errors.values.join('\n\n')),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: data.retry,
                        child: const Text('Tải lại dữ liệu'),
                      ),
                      TextButton(
                        onPressed: () => AuthScope.maybeOf(context)?.signOut(),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }
      final prefs = data.find('settings', 'preferences');
      final mode = prefs?.text('themeMode', 'system') ?? 'system';
      final isDark =
          mode == 'dark' ||
          mode == 'system' &&
              MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      final scale = switch (prefs?.text('fontSize')) {
        'small' => .9,
        'large' => 1.12,
        _ => 1.0,
      };
      final base = Theme.of(context);
      return Theme(
        data: base.copyWith(
          brightness: isDark ? Brightness.dark : Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D873A),
            brightness: isDark ? Brightness.dark : Brightness.light,
          ),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child,
        ),
      );
    },
  );
}
