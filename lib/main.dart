import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:study_planner_flutter/view/AU/auth_gate.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    /* AI reports missing configuration; Firebase remains available. */
  }
  runApp(const StudyPlannerFlutterApp());
}

class StudyPlannerFlutterApp extends StatefulWidget {
  const StudyPlannerFlutterApp({super.key});
  @override
  State<StudyPlannerFlutterApp> createState() => _StudyPlannerFlutterAppState();
}

class _StudyPlannerFlutterAppState extends State<StudyPlannerFlutterApp> {
  late Future<void> startup = initializeFirebase();
  Future<void> initializeFirebase() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('Firebase hiện chỉ được cấu hình cho Android.');
    }
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Study Planner',
    debugShowCheckedModeBanner: false,
    theme: buildStudyTheme(),
    home: FutureBuilder<void>(
      future: startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_outlined, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa thể khởi tạo Firebase',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hiện chỉ hỗ trợ Android. Kiểm tra google-services.json trong android/app, rồi build lại ứng dụng.',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          startup = initializeFirebase();
                        }),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const AuthGate();
      },
    ),
  );
}
