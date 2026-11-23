import 'dart:async';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/script_manager.dart';
import '../services/app_launcher.dart';
import '../theme/neon_theme.dart';
import '../screens/license_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _robloxFound = false;
  bool _injecting = false;
  bool _injected = false;
  String _status = 'Roblox aranıyor...';
  String _scriptPath = '';
  int _injectProgress = 0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _init();
  }

  Future<void> _init() async {
    await _requestPermissions();
    await _checkRoblox();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();
  }

  Future<void> _checkRoblox() async {
    final app = await DeviceApps.getApp('com.roblox.client');
    if (mounted) {
      setState(() {
        _robloxFound = app != null;
        _status = _robloxFound ? 'Roblox bulundu ✓' : 'Roblox bulunamadı';
      });
    }
  }

  Future<void> _inject() async {
    if (!_robloxFound) {
      _showSnack('Önce Roblox\'u yükle');
      return;
    }
    setState(() {
      _injecting = true;
      _injectProgress = 0;
    });

    try {
      _scriptPath = await ScriptManager.writeScript();
    } catch (e) {
      if (mounted) {
        setState(() {
          _injecting = false;
          _status = 'Script yazılamadı: $e';
        });
      }
      return;
    }

    _progressTimer =
        Timer.periodic(const Duration(milliseconds: 55), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _injectProgress += 3);
      if (_injectProgress >= 100) {
        t.cancel();
        setState(() {
          _injecting = false;
          _injected = true;
          _status = 'Hazır — Suzuki\'den execute et';
        });
      }
    });
  }

  Future<void> _launch() async {
    if (!_injected) {
      _showSnack('Önce inject et');
      return;
    }
    await AppLauncher.launchRoblox();
    await Future.delayed(const Duration(seconds: 2));
    final foundPkg = await AppLauncher.launchExecutor();
    if (mounted) {
      if (foundPkg != null) {
        _showSnack('Executor açıldı → Script\'i execute et');
      } else {
        _showSnack('Executor bulunamadı — Arceus X, Delta veya Fluxus yükle');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(color: NeonTheme.textPrimary)),
      backgroundColor: NeonTheme.bgCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: NeonTheme.neonBlue),
      ),
    ));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('license_key');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LicenseScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(painter: _GridPainter(), size: Size.infinite),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatusCard(),
                        const SizedBox(height: 16),
                        _buildGameCard(),
                        const SizedBox(height: 16),
                        if (_injecting) _buildProgressBar(),
                        if (_injected && !_injecting) _buildLaunchCard(),
                        const SizedBox(height: 16),
                        _buildInfoCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: NeonTheme.bgCard,
        border: Border(
          bottom: BorderSide(color: NeonTheme.neonBlue.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_alt,
              color: NeonTheme.neonBlue, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REAPER ENGINE',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: NeonTheme.neonBlue,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: NeonTheme.neonBlue, blurRadius: 10)
                  ],
                ),
              ),
              Text(
                'LOADER v1.0',
                style: GoogleFonts.orbitron(
                    fontSize: 9,
                    color: NeonTheme.textSecondary,
                    letterSpacing: 3),
              ),
            ],
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NeonTheme.neonBlue,
                boxShadow: [
                  BoxShadow(
                    color: NeonTheme.neonBlue
                        .withOpacity(_pulseController.value),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _logout,
            child: const Icon(Icons.logout,
                color: NeonTheme.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final color = _robloxFound ? Colors.greenAccent : Colors.orange;
    return Container(
      decoration: NeonTheme.glowBox(color: color),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            _robloxFound
                ? Icons.check_circle_outline
                : Icons.warning_amber,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_status,
                style: TextStyle(color: color, fontSize: 13)),
          ),
          if (!_robloxFound)
            GestureDetector(
              onTap: _checkRoblox,
              child: const Icon(Icons.refresh,
                  color: NeonTheme.neonBlue, size: 18),
            ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildGameCard() {
    return Container(
      decoration: NeonTheme.glowBox(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 3, height: 18, color: NeonTheme.neonBlue),
            const SizedBox(width: 8),
            Text('OYUN EKLE',
                style: GoogleFonts.orbitron(
                    fontSize: 12,
                    color: NeonTheme.textPrimary,
                    letterSpacing: 2)),
          ]),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: NeonTheme.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _injected
                    ? Colors.greenAccent.withOpacity(0.5)
                    : NeonTheme.border,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.gamepad,
                      color: NeonTheme.neonBlue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Roblox',
                          style: TextStyle(
                              color: NeonTheme.textPrimary,
                              fontWeight: FontWeight.bold)),
                      Text(
                        _robloxFound
                            ? 'com.roblox.client  •  Yüklü'
                            : 'Yüklü değil',
                        style: TextStyle(
                          color: _robloxFound
                              ? NeonTheme.textSecondary
                              : Colors.red.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                NeonButton(
                  label: _injected ? 'INJECT ✓' : 'INJECT',
                  color: _injected ? Colors.greenAccent : NeonTheme.neonBlue,
                  onTap: _injected ? () {} : _inject,
                  small: true,
                ),
              ],
            ),
          ),
          if (_scriptPath.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '📄 $_scriptPath',
              style: const TextStyle(
                  color: NeonTheme.textSecondary, fontSize: 10),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1);
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: NeonTheme.glowBox(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('INJECT EDİLİYOR...',
                  style: GoogleFonts.orbitron(
                      fontSize: 11,
                      color: NeonTheme.neonBlue,
                      letterSpacing: 2)),
              Text('${_injectProgress.clamp(0, 100)}%',
                  style: GoogleFonts.orbitron(
                      fontSize: 11, color: NeonTheme.neonBlue)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_injectProgress / 100).clamp(0.0, 1.0),
              backgroundColor: NeonTheme.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(NeonTheme.neonBlue),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(_progressLabel(),
              style: const TextStyle(
                  color: NeonTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  String _progressLabel() {
    if (_injectProgress < 20) return 'Roblox process aranıyor...';
    if (_injectProgress < 50) return 'Script hazırlanıyor...';
    if (_injectProgress < 80) return 'Dosya yazılıyor...';
    return 'Tamamlanıyor...';
  }

  Widget _buildLaunchCard() {
    return Container(
      decoration: NeonTheme.glowBox(color: Colors.greenAccent),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(children: [
            Container(width: 3, height: 18, color: Colors.greenAccent),
            const SizedBox(width: 8),
            Text('HAZIR',
                style: GoogleFonts.orbitron(
                    fontSize: 12,
                    color: Colors.greenAccent,
                    letterSpacing: 2)),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: NeonButton(
              label: 'OYUNU BAŞLAT',
              color: Colors.greenAccent,
              onTap: _launch,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Roblox açıldıktan sonra Suzuki\'yi aç\nve ReaperEngine.lua dosyasını execute et.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: NeonTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: NeonTheme.glowBox(color: NeonTheme.neonBlue2),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KULLANIM',
              style: GoogleFonts.orbitron(
                  fontSize: 10,
                  color: NeonTheme.textSecondary,
                  letterSpacing: 2)),
          const SizedBox(height: 10),
          _infoRow('1', 'INJECT butonuna bas'),
          _infoRow('2', 'OYUNU BAŞLAT butonuna bas'),
          _infoRow('3', 'Suzuki\'yi aç → ReaperEngine.lua → Execute'),
          _infoRow('4', 'Roblox\'ta sağ üst ☰ butonuna dokun'),
        ],
      ),
    );
  }

  Widget _infoRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: NeonTheme.neonBlue.withOpacity(0.5)),
            ),
            alignment: Alignment.center,
            child: Text(num,
                style: const TextStyle(
                    color: NeonTheme.neonBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: NeonTheme.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.03)
      ..strokeWidth = 0.5;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
