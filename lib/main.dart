import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NurTimeApp());
}

class NurTimeApp extends StatefulWidget {
  final AppStateController? controller;
  final String initialRoute;

  const NurTimeApp({
    super.key,
    this.controller,
    this.initialRoute = SplashScreen.routeName,
  });

  @override
  State<NurTimeApp> createState() => _NurTimeAppState();
}

class _NurTimeAppState extends State<NurTimeApp> {
  late final AppStateController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? AppStateController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      controller: _controller,
      child: MaterialApp(
        title: 'NurTime - Pengingat Sholat & Ngaji',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: widget.initialRoute,
        onGenerateInitialRoutes: (_) {
          // Pastikan setiap kali aplikasi dijalankan atau di-Hot Restart
          // (termasuk di Flutter Web), sesi selalu dimulai ulang dari initialRoute.
          final Route<dynamic> initialPage;
          if (widget.initialRoute == LoginScreen.routeName) {
            initialPage = MaterialPageRoute<void>(
              settings: const RouteSettings(name: LoginScreen.routeName),
              builder: (_) => const LoginScreen(),
            );
          } else if (widget.initialRoute == MainShell.routeName) {
            initialPage = MaterialPageRoute<void>(
              settings: const RouteSettings(name: MainShell.routeName),
              builder: (_) => const MainShell(),
            );
          } else {
            initialPage = MaterialPageRoute<void>(
              settings: const RouteSettings(name: SplashScreen.routeName),
              builder: (_) => const SplashScreen(),
            );
          }
          return [initialPage];
        },
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          MainShell.routeName: (_) => const MainShell(),
        },
      ),
    );
  }
}
