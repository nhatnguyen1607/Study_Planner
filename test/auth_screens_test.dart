import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:study_planner_flutter/services/firestore_user_profile_repository.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/view/AU/auth_gate.dart';
import 'package:study_planner_flutter/view/AU/login_screen.dart';
import 'package:study_planner_flutter/view/AU/register_screen.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';
import 'package:study_planner_flutter/viewmodel/auth_view_model.dart';
import 'package:study_planner_flutter/view/common/study_widgets.dart';

import 'fake_auth_repository.dart';

void main() {
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final style in ['Regular', 'Medium', 'Bold']) {
      final file = File('test/fonts/Roboto-$style.ttf');
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(await file.readAsBytes())));
      await loader.load();
    }
  });
  for (final registering in [false, true]) {
    testWidgets('Auth layout: register=$registering', (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      for (final width in [320.0, 390.0]) {
        tester.view.physicalSize = Size(width, 844);
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildStudyTheme(),
            home: RepaintBoundary(
              key: key,
              child: registering
                  ? RegisterScreen(
                      onLogin: () {},
                      onSubmit: (email, password, name) async => null,
                    )
                  : LoginScreen(
                      onRegister: () {},
                      onSubmit: (email, password, name) async => null,
                    ),
            ),
          ),
        );
        await tester.runAsync(() async {
          final context = tester.element(find.byType(Scaffold).first);
          for (final asset in [
            'assets/images/study_planner_bg.png',
            'assets/images/home_welcome.png',
            'assets/images/goals_new_seed.png',
          ]) {
            await precacheImage(AssetImage(asset), context);
          }
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (width == 390) {
          await tester.runAsync(() async {
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = (await image.toByteData(
              format: ui.ImageByteFormat.png,
            ))!;
            final file = File(
              'build/auth_${registering ? 'register' : 'login'}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes.buffer.asUint8List());
            image.dispose();
          });
        }
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.tap(find.byType(TextFormField).first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.widgetWithText(
            PrimaryStudyButton,
            registering ? 'Tạo tài khoản' : 'Đăng nhập',
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
      }
    });
  }
  testWidgets('Auth switches, validates and enters an authenticated session', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeAuthRepository();
    final auth = AuthViewModel(repository);
    addTearDown(auth.dispose);
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildStudyTheme(),
        home: AuthGate(
          syncState: false,
          auth: auth,
          profiles: FirestoreUserProfileRepository(
            firestore: FakeFirebaseFirestore(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PrimaryStudyButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    await tester.ensureVisible(find.text('Đăng ký ngay'));
    await tester.tap(find.text('Đăng ký ngay'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Minh Anh');
    await tester.enterText(fields.at(1), 'anh@example.com');
    await tester.enterText(fields.at(2), 'demo12345');
    await tester.enterText(fields.at(3), 'wrong');
    await tester.ensureVisible(
      find.widgetWithText(PrimaryStudyButton, 'Tạo tài khoản'),
    );
    await tester.tap(find.widgetWithText(PrimaryStudyButton, 'Tạo tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('Mật khẩu xác nhận chưa khớp'), findsOneWidget);
    await tester.enterText(fields.at(3), 'demo12345');
    await tester.ensureVisible(
      find.widgetWithText(PrimaryStudyButton, 'Tạo tài khoản'),
    );
    await tester.tap(find.widgetWithText(PrimaryStudyButton, 'Tạo tài khoản'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
