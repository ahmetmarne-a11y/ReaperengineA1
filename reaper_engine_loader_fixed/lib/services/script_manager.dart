import 'dart:io';
import 'package:flutter/services.dart';

class ScriptManager {
  static const _suzukiPath = '/sdcard/Suzuki/scripts/ReaperEngine.lua';
  static const _altPath = '/sdcard/Download/ReaperEngine.lua';

  static Future<String> writeScript() async {
    final scriptContent =
        await rootBundle.loadString('assets/reaper_script.lua');

    final suzukiDir = Directory('/sdcard/Suzuki/scripts');
    String targetPath;

    if (await suzukiDir.exists()) {
      targetPath = _suzukiPath;
    } else {
      targetPath = _altPath;
    }

    final file = File(targetPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(scriptContent);
    return targetPath;
  }

  static Future<bool> suzukiInstalled() async {
    final dir = Directory('/sdcard/Suzuki');
    return await dir.exists();
  }
}
