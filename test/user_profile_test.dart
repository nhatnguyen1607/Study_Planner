import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/model/auth_user.dart';
import 'package:study_planner_flutter/model/user_profile.dart';
import 'package:study_planner_flutter/services/firestore_user_profile_repository.dart';
import 'package:study_planner_flutter/viewmodel/user_profile_view_model.dart';

void main() {
  const user = AuthUser(
    uid: 'uid-alice',
    email: 'alice@example.com',
    displayName: 'Alice',
  );
  test('Creates exactly user/{uid}, initializes optional fields and server timestamps', () async {
    final db = FakeFirebaseFirestore();
    final repo = FirestoreUserProfileRepository(firestore: db);
    await repo.ensureUser(user);
    final documents = await db.collection('user').get();
    expect(documents.docs.length, 1);
    final document = documents.docs.single;
    expect(document.id, user.uid);
    final data = document.data();
    expect(data['uid'], user.uid);
    expect(data['email'], user.email);
    expect(data['displayName'], 'Alice');
    expect(data['school'], isNull);
    expect(data['bio'], isNull);
    expect(data['createdAt'], isA<Timestamp>());
    expect(data['updatedAt'], isA<Timestamp>());
    expect(data['notifications'], UserProfile.notificationDefaults);
    expect(data['preferences'], UserProfile.preferenceDefaults);
    expect(data.containsKey('password'), false);
    expect(data.containsKey('admin'), false);
  });
  test(
    'Re-entering a session does not overwrite saved profile or preferences',
    () async {
      final db = FakeFirebaseFirestore();
      final repo = FirestoreUserProfileRepository(firestore: db);
      await repo.ensureUser(user);
      final ref = db.collection('user').doc(user.uid);
      final createdAt = (await ref.get()).data()!['createdAt'];
      await ref.update({
        'school': 'Trường A',
        'displayName': 'Tên đã sửa',
        'preferences.themeMode': 'dark',
      });
      await repo.ensureUser(user);
      final data = (await ref.get()).data()!;
      expect(data['school'], 'Trường A');
      expect(data['displayName'], 'Tên đã sửa');
      expect(data['preferences']['themeMode'], 'dark');
      expect(data['createdAt'], createdAt);
      expect((await db.collection('user').get()).docs.length, 1);
    },
  );
  test(
    'Profile save updates only editable fields and preserves ownership',
    () async {
      final db = FakeFirebaseFirestore();
      final repo = FirestoreUserProfileRepository(firestore: db);
      await repo.ensureUser(user);
      await repo.save(
        const UserProfile(
          uid: 'uid-alice',
          email: 'ignored@example.com',
          displayName: ' Alice mới ',
          bio: '',
          studyRole: 'Sinh viên',
          school: 'Trường A',
        ),
      );
      final data = (await db.collection('user').doc(user.uid).get()).data()!;
      expect(data['email'], user.email);
      expect(data['displayName'], 'Alice mới');
      expect(data['bio'], isNull);
      expect(data['studyRole'], 'Sinh viên');
      expect(data['school'], 'Trường A');
      expect(data['notifications'], UserProfile.notificationDefaults);
      expect((await repo.watch(user.uid).first)?.displayName, 'Alice mới');
    },
  );
  test('ViewModel rejects other UIDs and invalid profile fields', () async {
    final repo = FirestoreUserProfileRepository(
      firestore: FakeFirebaseFirestore(),
    );
    final vm = UserProfileViewModel(user, repo);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(vm.profile?.uid, user.uid);
    expect(
      await vm.save(
        const UserProfile(uid: 'another', email: '', displayName: 'Name'),
      ),
      isNotNull,
    );
    expect(
      await vm.save(
        const UserProfile(uid: 'uid-alice', email: '', displayName: ''),
      ),
      isNotNull,
    );
    vm.dispose();
  });
}
