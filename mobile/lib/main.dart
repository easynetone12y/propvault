import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  final home = await AppRouter.getInitialScreen();
  runApp(PropVaultApp(home: home));
}

class PropVaultApp extends StatelessWidget {
  final Widget home;
  const PropVaultApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PropVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
