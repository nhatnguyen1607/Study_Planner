import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/model/auth_user.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/services/firestore_user_profile_repository.dart';
import 'package:study_planner_flutter/view/AU/user_profile_gate.dart';
import 'package:study_planner_flutter/view/PR/pr02.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';
import 'package:study_planner_flutter/viewmodel/user_profile_view_model.dart';

void main() {
  testWidgets('Settings edits an empty profile and persists its fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = FakeFirebaseFirestore();
    final repo = FirestoreUserProfileRepository(firestore: db);
    const user = AuthUser(
      uid: 'alice',
      email: 'alice@example.com',
      displayName: 'Alice',
    );
    final profile = UserProfileViewModel(user, repo);
    final planner = StudyPlannerViewModel()..navigate(StudyDestination.pr02);
    addTearDown(profile.dispose);
    addTearDown(planner.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildStudyTheme(),
        home: UserProfileScope(
          profile: profile,
          child: Pr02Screen(viewModel: planner),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // The form must also initialize if the profile stream arrives after first build.
    final fields = find.byType(TextFormField);
    expect(
      (tester.widget<TextFormField>(fields.at(0))).controller!.text,
      'Alice',
    );
    expect((tester.widget<TextFormField>(fields.at(3))).controller!.text, '');
    await tester.enterText(fields.at(0), 'Alice mới');
    await tester.enterText(fields.at(1), 'Thích học lập trình');
    await tester.enterText(fields.at(2), 'Sinh viên');
    await tester.enterText(fields.at(3), 'Trường A');
    await tester.ensureVisible(find.text('Lưu thay đổi'));
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();
    final data = (await db.doc('user/alice').get()).data()!;
    expect(data['displayName'], 'Alice mới');
    expect(data['school'], 'Trường A');
    expect(data['studyRole'], 'Sinh viên');
    expect(data['email'], user.email);
    expect(planner.destination, StudyDestination.pr01);
    expect(tester.takeException(), isNull);
  });
}
