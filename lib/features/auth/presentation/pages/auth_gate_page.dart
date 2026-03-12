import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/premium_glass.dart';
import '../../../../core/widgets/liquid_glass_button.dart';
import '../../../simulacao/presentation/pages/home_page.dart';
import 'auth_screen.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> with TickerProviderStateMixin {
  late final AnimationController _blobCtrl1;
  late final AnimationController _blobCtrl2;

  @override
  void initState() {
    super.initState();
    _blobCtrl1 = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _blobCtrl2 = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobCtrl1.dispose();
    _blobCtrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2C59), // Deep Navy background
      body: Stack(
        children: [
          _buildFloatingBlobs(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildBranding(),
                  const SizedBox(height: 60),
                  _buildGlassForm(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBlobs() {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _blobCtrl2,
          builder: (_, _) {
            final dx = math.sin(_blobCtrl2.value * math.pi) * 10;
            final dy = math.cos(_blobCtrl2.value * math.pi) * 15;
            return Positioned(
              top: -80 + dy,
              right: -80 + dx,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00B4D8).withValues(alpha: 0.15), // Cyan
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _blobCtrl1,
          builder: (_, _) {
            final dx = math.cos(_blobCtrl1.value * math.pi) * 10;
            final dy = math.sin(_blobCtrl1.value * math.pi) * 15;
            return Positioned(
              bottom: -80 + dy,
              left: -80 + dx,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00B4D8).withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B4D8).withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/logo_transparent.png',
              width: 60,
              height: 60,
            ),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 24),
        Text(
          'Aceda à sua Conta',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
        const SizedBox(height: 12),
        Text(
          'Gira os seus seguros, obtenha cotações detalhadas e usufrua dos nossos serviços.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 15,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildGlassForm(BuildContext context) {
    return PremiumGlass(
      borderRadius: 32,
      padding: const EdgeInsets.all(28),
      gradientOpacityStart: 0.15,
      gradientOpacityEnd: 0.05,
      borderOpacity: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LiquidGlassButton(
            label: 'Entrar / Registar',
            color: const Color(0xFF00B4D8), // Cyan
            borderRadius: 16,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OU',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(), // Simulation flow
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00B4D8),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  'Simular Agora',
                  style: const TextStyle(
                    color: Color(0xFF00B4D8),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2);
  }
}
