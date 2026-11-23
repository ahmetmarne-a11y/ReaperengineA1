import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/license_screen.dart';
import 'theme/neon_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ReaperEngineApp());
}

class ReaperEngineApp extends StatelessWidget {
  const ReaperEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReaperEngine Loader',
      debugShowCheckedModeBanner: false,
      theme: NeonTheme.theme,
      home: const LicenseScreen(),
    );
  }
}
