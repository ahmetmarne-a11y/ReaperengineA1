import 'package:url_launcher/url_launcher.dart';

class AppLauncher {
  static const _robloxPackage = 'com.roblox.client';

  // Bilinen executor package adları (sırayla dener)
  static const _executors = [
    'com.arceusxneo',           // Arceus X Neo
    'com.arceusx.executor',     // Arceus X (eski)
    'com.delta.executor',       // Delta
    'com.hydrogen.executor',    // Hydrogen
    'air.Fluxus',               // Fluxus
    'com.fluxus.executor',      // Fluxus alt
    'com.vega.executor',        // Vega X
    'com.codex.executor',       // Codex
    'com.pet.executor',         // Pet Simulator executor
    'com.moe.shizuku.privileged.api', // Shizuku (fallback)
  ];

  static Future<void> launchRoblox() async {
    final appUri = Uri.parse('android-app://$_robloxPackage');
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(
        Uri.parse('https://play.google.com/store/apps/details?id=$_robloxPackage'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  /// Yüklü olan ilk executor'ı bulur ve açar.
  /// Bulunan executor'ın adını döner, bulunamazsa null.
  static Future<String?> launchExecutor() async {
    for (final pkg in _executors) {
      final uri = Uri.parse('android-app://$pkg');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return pkg;
      }
    }
    return null;
  }
}
