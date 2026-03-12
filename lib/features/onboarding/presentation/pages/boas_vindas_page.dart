import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../auth/presentation/pages/auth_screen.dart';
import '../../../../core/widgets/premium_glass.dart';
import '../../../../core/widgets/liquid_glass_button.dart';

class _SlideData {
  const _SlideData({
    required this.headline1,
    required this.headline2,
    required this.subtitle,
    required this.backgroundImage,
    this.badgeIcon,
    this.badgeText,
  });

  final String headline1;
  final String headline2;
  final String subtitle;
  final String backgroundImage;
  final IconData? badgeIcon;
  final String? badgeText;
}

class BoasVindasPage extends StatefulWidget {
  const BoasVindasPage({super.key});

  @override
  State<BoasVindasPage> createState() => _BoasVindasPageState();
}

class _BoasVindasPageState extends State<BoasVindasPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const String _bgImage = 'assets/images/smiling_black_woman.png';

  static final List<_SlideData> _slides = [
    const _SlideData(
      headline1: 'Viva ',
      headline2: 'Sem Medo.',
      subtitle:
          'Simule e contrate o seu Seguro Automóvel ou Funeral em minutos com o aplicativo da Indico Seguros.',
      backgroundImage: _bgImage,
      badgeIcon: Icons.shield_rounded,
      badgeText: 'Proteção Máxima',
    ),
    const _SlideData(
      headline1: 'Proteção Rápida',
      headline2: 'e Simples',
      subtitle:
          'Gere as suas apólices e reporte acidentes diretamente do seu telemóvel, onde quer que esteja.',
      backgroundImage: _bgImage,
      badgeIcon: Icons.health_and_safety_rounded,
      badgeText: 'Cobertura Total',
    ),
    const _SlideData(
      headline1: 'Partilhe e',
      headline2: 'Ganhe Dinheiro',
      subtitle:
          'Recomende o aplicativo Viva Sem Medo aos seus amigos e receba comissões diretamente na sua conta.',
      backgroundImage: _bgImage,
      badgeIcon: Icons.diversity_1_rounded,
      badgeText: 'Programa de Indicação',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onGetStarted() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const AuthScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F2C59), // Deep Navy background
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return _OnboardingSlide(
                headline1: slide.headline1,
                headline2: slide.headline2,
                subtitle: slide.subtitle,
                backgroundImage: slide.backgroundImage,
                currentPage: _currentPage,
                totalPages: _slides.length,
                onNext: _goToNext,
                onGetStarted: _onGetStarted,
                badgeIcon: slide.badgeIcon,
                badgeText: slide.badgeText,
              );
            },
          ),
          Positioned(
            top: 48,
            right: 24,
            child: GestureDetector(
              onTap: _onGetStarted,
              child: Text(
                'Pular',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatefulWidget {
  const _OnboardingSlide({
    required this.headline1,
    required this.headline2,
    required this.subtitle,
    required this.backgroundImage,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onGetStarted,
    this.badgeIcon,
    this.badgeText,
  });

  final String headline1;
  final String headline2;
  final String subtitle;
  final String backgroundImage;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;
  final IconData? badgeIcon;
  final String? badgeText;

  bool get isLastPage => currentPage == totalPages - 1;

  @override
  State<_OnboardingSlide> createState() => _OnboardingSlideState();
}

class _OnboardingSlideState extends State<_OnboardingSlide>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _chevronCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 15))
      ..repeat(reverse: true);
    _chevronCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _chevronCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardTop = screenHeight > 800 ? screenHeight * 0.60 : screenHeight * 0.55;
    final gradientTop = screenHeight > 800 ? screenHeight * 0.45 : screenHeight * 0.40;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -50, left: 0, right: 0, bottom: 0,
          child: AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, _) => Transform.scale(
              scale: 1.05 + (_bgCtrl.value * 0.05),
              alignment: Alignment.center,
              child: Image.asset(
                widget.backgroundImage,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
        
        Positioned(
          top: gradientTop, left: 0, right: 0, bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
                colors: [
                  Colors.transparent,
                  const Color(0xFF0F2C59).withValues(alpha: 0.8), // Deep Navy
                  const Color(0xFF0F2C59),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: cardTop, left: 0, right: 0, bottom: 0,
          child: PremiumGlass(
            borderRadius: 32,
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
            gradientOpacityStart: 0.15,
            gradientOpacityEnd: 0.05,
            borderOpacity: 0.3,
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.headline1,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                  ),
                  Text(
                    widget.headline2,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF00B4D8), // Cyan
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                          fontSize: 15,
                        ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 8), // Espaço extra de garantia
                  widget.isLastPage
                      ? _buildLastPageNav()
                      : _buildDotsAndArrow(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),

        if (widget.badgeIcon != null && widget.badgeText != null)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, top: 48, right: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_transparent.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDotsAndArrow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: List.generate(widget.totalPages, (i) {
              final isActive = i == widget.currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF00B4D8)
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _chevronCtrl,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.2;
                    final progress = ((_chevronCtrl.value + delay) % 1.0);
                    final opacity = progress < 0.5
                        ? progress * 2
                        : (1.0 - progress) * 2;
                    return Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onNext,
              child: LiquidGlassButton(
                label: '',
                width: 52,
                height: 52,
                borderRadius: 26,
                color: const Color(0xFF00B4D8), // Cyan
                onTap: widget.onNext,
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLastPageNav() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.totalPages, (i) {
            final isActive = i == widget.currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 6),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF00B4D8)
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        LiquidGlassButton(
          label: 'Começar',
          color: const Color(0xFF00B4D8), // Cyan
          borderRadius: 16,
          onTap: widget.onGetStarted,
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.badgeIcon,
            color: const Color(0xFF00B4D8),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            widget.badgeText!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
