import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nur_time_app/main.dart';
import 'package:nur_time_app/screens/login_screen.dart';
import 'package:nur_time_app/screens/main_shell.dart';
import 'package:nur_time_app/state/app_state.dart';

void main() {
  testWidgets('Login validation blocks empty submit and allows valid login',
      (WidgetTester tester) async {
    final controller = AppStateController(startTimer: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      NurTimeApp(
        controller: controller,
        initialRoute: LoginScreen.routeName,
      ),
    );
    await tester.pumpAndSettle();

    // Submit empty form
    await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Nama lengkap tidak boleh kosong'), findsOneWidget);
    expect(find.text('Kata sandi tidak boleh kosong'), findsOneWidget);

    // Fill demo data and submit
    await tester.ensureVisible(find.byKey(const Key('login_demo_button')));
    await tester.tap(find.byKey(const Key('login_demo_button')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(controller.isLoggedIn, isTrue);
    expect(find.textContaining('Assalamu\'alaikum, Muhammad Rangga'), findsOneWidget);
  });

  testWidgets('Tilawah tracker validates input and updates state',
      (WidgetTester tester) async {
    final controller = AppStateController(startTimer: false);
    controller.login(name: 'Muhammad Rangga', nim: '4342501025', city: 'Batam');
    addTearDown(controller.dispose);

    final initialAyat = controller.totalAyatReadToday;

    await tester.pumpWidget(
      NurTimeApp(
        controller: controller,
        initialRoute: MainShell.routeName,
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Ngaji tab
    await tester.tap(find.text('Ngaji'));
    await tester.pumpAndSettle();

    // Open Catat Ngaji modal
    await tester.tap(find.byKey(const Key('add_tilawah_fab')));
    await tester.pumpAndSettle();

    // Try invalid ayat > Al-Fatihah (7 ayat)
    await tester.enterText(find.byKey(const Key('tilawah_end_field')), '20');
    await tester.tap(find.byKey(const Key('tilawah_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Melebihi 7 ayat'), findsOneWidget);

    // Enter valid ayat
    await tester.enterText(find.byKey(const Key('tilawah_end_field')), '7');
    await tester.tap(find.byKey(const Key('tilawah_save_button')));
    await tester.pumpAndSettle();

    expect(controller.totalAyatReadToday, equals(initialAyat + 7));
  });

  testWidgets('State survives orientation change and tasbih updates cleanly',
      (WidgetTester tester) async {
    final controller = AppStateController(startTimer: false);
    controller.login(name: 'Muhammad Rangga', nim: '4342501025', city: 'Batam');
    addTearDown(controller.dispose);

    // Start in portrait
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      NurTimeApp(
        controller: controller,
        initialRoute: MainShell.routeName,
      ),
    );
    await tester.pumpAndSettle();

    // Go to Tasbih tab and tap 3 times
    await tester.tap(find.text('Tasbih'));
    await tester.pumpAndSettle();

    for (int i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('tasbih_tap_button')));
      await tester.pump();
    }
    expect(controller.tasbihCount, equals(3));

    // Switch to landscape (wide screen)
    tester.view.physicalSize = const Size(840, 400);
    await tester.pumpAndSettle();

    // State must remain intact (no overflow, count still 3)
    expect(controller.tasbihCount, equals(3));
    expect(find.text('3'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('Sync prayer schedule handles offline exception safely', () async {
    final controller = AppStateController(startTimer: false);
    addTearDown(controller.dispose);

    await expectLater(
      () => controller.syncPrayerSchedule(simulateOfflineError: true),
      throwsException,
    );
    expect(controller.isSyncing, isFalse);
    expect(controller.lastSyncMessage, contains('Koneksi internet terputus'));
  });

  testWidgets('Splash screen preview works from Profile without losing state',
      (WidgetTester tester) async {
    final controller = AppStateController(startTimer: false);
    controller.login(name: 'Muhammad Rangga', nim: '4342501025', city: 'Batam');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      NurTimeApp(
        controller: controller,
        initialRoute: MainShell.routeName,
      ),
    );
    await tester.pumpAndSettle();

    // Open Profile tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Tap Pratinjau Splash Screen
    await tester.ensureVisible(find.text('Pratinjau Splash Screen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pratinjau Splash Screen'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify splash preview renders and stays open without auto-redirecting
    expect(find.text('NurTime'), findsOneWidget);
    expect(find.text('← Kembali ke Aplikasi'), findsOneWidget);

    // Return to Profile and confirm login state preserved
    await tester.tap(find.text('← Kembali ke Aplikasi'));
    await tester.pumpAndSettle();

    expect(controller.isLoggedIn, isTrue);
    expect(find.text('Profil & Pengaturan'), findsOneWidget);
  });

  testWidgets('Default NurTimeApp startup begins at SplashScreen and moves to Login',
      (WidgetTester tester) async {
    final controller = AppStateController(startTimer: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(NurTimeApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('NurTime'), findsOneWidget);
    expect(find.text('Mulai Sekarang →'), findsOneWidget);

    // Wait past 3s timer to reach LoginScreen
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Masuk Akun Pengguna'), findsOneWidget);
  });
}
