import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/widgets/premium_glass.dart';
import '../../../../core/widgets/liquid_glass_button.dart';
import '../../../simulacao/presentation/pages/simulation_wizard.dart';
import '../../../home/presentation/pages/main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthScreen extends StatefulWidget {
  final bool initialIsRegisterMode;
  
  const AuthScreen({
    super.key,
    this.initialIsRegisterMode = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late bool _isRegisterMode;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _blobCtrl1;
  late final AnimationController _blobCtrl2;

  // Viva Sem Medo Colors
  final Color primaryColor = const Color(0xFF00B4D8); // Cyan
  final Color secondaryColor = const Color(0xFF0F2C59); // Navy Blue
  final Color backgroundColor = const Color(0xFFF8F9FA); // Off White / Light

  @override
  void initState() {
    super.initState();
    _isRegisterMode = widget.initialIsRegisterMode;
    _blobCtrl1 = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _blobCtrl2 = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _blobCtrl1.dispose();
    _blobCtrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // ── Floating gradient blobs (Light Mode Adapted) ──
          _buildFloatingBlobs(),

          // ── Main content ──
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(),
                          // ── Logo + Branding ──
                          _buildBranding(),
                          const SizedBox(height: 32),
                          // ── Glass Card Form ──
                          _buildGlassForm(),
                          const SizedBox(height: 24),
                          // ── Create Account link ──
                          _buildCreateAccountLink(),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: secondaryColor),
              onPressed: () => Navigator.of(context).pop(),
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
                      primaryColor.withValues(alpha: 0.15),
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
                      secondaryColor.withValues(alpha: 0.1),
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/logo_transparent.png', // Assuming this asset exists in Viva Sem Medo
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image not found
                return Icon(Icons.security, color: secondaryColor, size: 40);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            children: [
              TextSpan(
                text: 'Viva Sem ',
                style: TextStyle(color: secondaryColor),
              ),
              TextSpan(
                text: 'Medo',
                style: TextStyle(color: primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildGlassForm() {
    return PremiumGlass(
      borderRadius: 28,
      padding: EdgeInsets.zero,
      gradientOpacityStart: 0.6, // Higher opacity for light mode
      gradientOpacityEnd: 0.3,
      borderOpacity: 0.5,
      child: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  primaryColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _isRegisterMode ? 'Criar Conta' : 'Bem-vindo(a)',
                      key: ValueKey(_isRegisterMode),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: secondaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRegisterMode
                        ? 'Registe-se para proteger o seu futuro'
                        : 'Entre para aceder aos seus seguros',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: secondaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_isRegisterMode) ...[
                    _buildInputField(
                      label: 'NOME COMPLETO',
                      hint: 'O seu nome',
                      icon: Icons.person_outline_rounded,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'TELEFONE',
                      hint: '+258 8x xxx xxxx',
                      icon: Icons.phone_android_rounded,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildInputField(
                    label: 'EMAIL',
                    hint: 'name@example.com',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  _buildPasswordField(
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    label: 'SENHA',
                    showForgot: !_isRegisterMode,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),

                  if (_isRegisterMode) ...[
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      obscure: _obscureConfirmPassword,
                      label: 'CONFIRMAR SENHA',
                      showForgot: false,
                      onToggle: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ],

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  _buildActionButton(),
                  const SizedBox(height: 16),
                  _buildSimulateButton(),

                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 16),
                  _buildSocialButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: secondaryColor.withValues(alpha: 0.7),
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: secondaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: secondaryColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: secondaryColor.withValues(alpha: 0.3),
              ),
              prefixIcon: Icon(
                icon,
                color: secondaryColor.withValues(alpha: 0.5),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required String label,
    required bool showForgot,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: secondaryColor.withValues(alpha: 0.7),
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showForgot)
                GestureDetector(
                  onTap: () {
                    // Navigate to forgot password
                  },
                  child: Text(
                    'Esqueceu?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: secondaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: secondaryColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: secondaryColor.withValues(alpha: 0.3),
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: secondaryColor.withValues(alpha: 0.5),
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: secondaryColor.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return LiquidGlassButton(
      label: _isRegisterMode ? 'Registar' : 'Entrar',
      color: primaryColor,
      isLoading: _isLoading,
      onTap: () async {
        setState(() => _errorMessage = null);
        
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        
        if (email.isEmpty || password.isEmpty) {
          setState(() => _errorMessage = 'Preencha todos os campos obrigatórios.');
          return;
        }
        
        if (_isRegisterMode) {
          if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
            setState(() => _errorMessage = 'Preencha todos os dados de registo.');
            return;
          }
          if (password != _confirmPasswordController.text) {
            setState(() => _errorMessage = 'As senhas não coincidem.');
            return;
          }
        }
        
        setState(() => _isLoading = true);
        
        try {
          if (_isRegisterMode) {
            await _authRepository.createUserWithEmailAndPassword(
              email: email,
              password: password,
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
            );
          } else {
            await _authRepository.signInWithEmailAndPassword(email, password);
          }
          
          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
            );
          }
        } on FirebaseAuthException catch (e) {
          print('====== FirebaseAuthException ======');
          print('Code: ${e.code}');
          print('Message: ${e.message}');
          print('====================================');
          if (mounted) {
            setState(() {
              _isLoading = false;
              switch (e.code) {
                case 'user-not-found':
                  _errorMessage = 'Utilizador não encontrado. Crie uma conta.';
                  break;
                case 'wrong-password':
                  _errorMessage = 'Palavra-passe incorreta.';
                  break;
                case 'email-already-in-use':
                  _errorMessage = 'O email já está em uso.';
                  break;
                case 'invalid-email':
                  _errorMessage = 'Email inválido.';
                  break;
                case 'weak-password':
                  _errorMessage = 'A senha é muito fraca.';
                  break;
                case 'invalid-credential':
                  _errorMessage = 'Credenciais inválidas. Verifique o seu email e senha.';
                  break;
                default:
                  _errorMessage = 'Erro na autenticação: ${e.message}';
              }
            });
          }
        } catch (e, stackTrace) {
          print('====== ERRO NA AUTENTICAÇÃO ======');
          print('Tipo do erro: ${e.runtimeType}');
          print('Erro Nativo JS: $e');
          print('StackTrace: \\n$stackTrace');
          print('==================================');
          if (mounted) {
            setState(() {
              _errorMessage = 'Erro interno. Veja a consola local para detalhes.';
              _isLoading = false;
            });
          }
        }
      },
    );
  }

  Widget _buildSimulateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          highlightColor: primaryColor.withValues(alpha: 0.1),
          splashColor: primaryColor.withValues(alpha: 0.2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimulationWizard(),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calculate_outlined, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Simular Seguro',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: secondaryColor.withValues(alpha: 0.1)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ou continue com',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: secondaryColor.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: secondaryColor.withValues(alpha: 0.1)),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: SvgPicture.asset(
              'assets/icons/google_logo.svg', // Ensure this asset exists
              width: 20,
              height: 20,
              // Fallback
              placeholderBuilder: (BuildContext context) => 
                  Icon(Icons.g_mobiledata, color: secondaryColor, size: 30),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSocialButton(
            icon: Icon(Icons.apple_rounded, color: secondaryColor, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({required Widget icon}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: secondaryColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withValues(alpha: 0.1),
          child: Center(child: icon),
        ),
      ),
    );
  }

  Widget _buildCreateAccountLink() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isRegisterMode = !_isRegisterMode;
          _errorMessage = null;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: RichText(
          key: ValueKey(_isRegisterMode),
          text: TextSpan(
            children: [
              TextSpan(
                text: _isRegisterMode ? 'Já tem conta? ' : 'Não tem uma conta? ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: secondaryColor.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: _isRegisterMode ? 'Entrar' : 'Criar Conta',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
