import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/neon_theme.dart';
import 'main_screen.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _error = false;
  bool _loading = false;
  late AnimationController _scanController;

  static const _validKey = '@ReaperEngine';

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _checkSaved();
  }

  Future<void> _checkSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('license_key');
    if (saved == _validKey && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    await Future.delayed(const Duration(milliseconds: 800));

    if (_controller.text.trim() == _validKey) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('license_key', _validKey);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } else {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(painter: _GridPainter(), size: Size.infinite),
          AnimatedBuilder(
            animation: _scanController,
            builder: (_, __) {
              final h = MediaQuery.of(context).size.height;
              return Positioned(
                top: _scanController.value * h,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      NeonTheme.neonBlue.withOpacity(0.6),
                      NeonTheme.neonBlue,
                      NeonTheme.neonBlue.withOpacity(0.6),
                      Colors.transparent,
                    ]),
                  ),
                ),
              );
            },
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 40),
                  _buildCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: NeonTheme.glowBox(blur: 24),
          child: const Icon(
            Icons.psychology_alt,
            color: NeonTheme.neonBlue,
            size: 44,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.5, 0.5)),
        const SizedBox(height: 16),
        Text(
          'REAPER ENGINE',
          style: GoogleFonts.orbitron(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: NeonTheme.neonBlue,
            letterSpacing: 4,
            shadows: [
              Shadow(
                  color: NeonTheme.neonBlue.withOpacity(0.8), blurRadius: 20),
              Shadow(
                  color: NeonTheme.neonBlue.withOpacity(0.4), blurRadius: 40),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
        const SizedBox(height: 4),
        Text(
          'LOADER  v1.0',
          style: GoogleFonts.orbitron(
            fontSize: 11,
            color: NeonTheme.textSecondary,
            letterSpacing: 6,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: NeonTheme.glowBox(blur: 20),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: NeonTheme.neonBlue,
                  boxShadow: [
                    BoxShadow(color: NeonTheme.neonBlue, blurRadius: 8)
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'LİSANS DOĞRULAMA',
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  color: NeonTheme.textPrimary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Lisans Anahtarı',
            style:
                TextStyle(color: NeonTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: GoogleFonts.sourceCodePro(
              color: NeonTheme.neonBlue,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: '@ReaperEngine',
              hintStyle: TextStyle(
                  color: NeonTheme.textSecondary.withOpacity(0.5)),
              filled: true,
              fillColor: NeonTheme.bg,
              prefixIcon: Icon(Icons.vpn_key_outlined,
                  color: _error ? Colors.red : NeonTheme.neonBlue, size: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _error ? Colors.red : NeonTheme.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: NeonTheme.neonBlue, width: 1.5),
              ),
              errorText: _error ? 'Geçersiz lisans anahtarı' : null,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: NeonTheme.neonBlue, strokeWidth: 2))
                : NeonButton(label: 'GİRİŞ YAP', onTap: _submit),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.04)
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

class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool small;

  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = NeonTheme.neonBlue,
    this.small = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: widget.color, width: 1.5),
          color: widget.color.withOpacity(_pressed ? 0.3 : 0.1),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_pressed ? 0.5 : 0.25),
              blurRadius: _pressed ? 20 : 12,
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: widget.small
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : null,
        child: Text(
          widget.label,
          style: GoogleFonts.orbitron(
            fontSize: widget.small ? 10 : 13,
            fontWeight: FontWeight.w700,
            color: widget.color,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}
