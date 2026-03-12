import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 120.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildSearchBar(context),
              const SizedBox(height: 32),
              _buildLatestPolicyCard(context),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Acesso Rápido',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildQuickAccess(context),
              const SizedBox(height: 32),
              _buildReferralCard(context),
              const SizedBox(height: 32),
              _buildPoliciesSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=32'), // Avatar de exemplo
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem vindo,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
                Text(
                  FirebaseAuth.instance.currentUser?.displayName ??
                      FirebaseAuth.instance.currentUser?.email?.split('@').first ??
                      'Utilizador',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimaryColor),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Pesquisar seguros, apólices...',
          hintStyle: const TextStyle(color: AppTheme.textSecondaryColor),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondaryColor),
          suffixIcon: const Icon(Icons.tune_rounded, color: AppTheme.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLatestPolicyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_car_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seguro Automóvel',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Cobertura Total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Ativa',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prémio Mensal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1,500 MT',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Ver Apólice', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          context,
          icon: Icons.add_moderator_rounded,
          label: 'Simular',
          color: AppTheme.primaryColor,
          onTap: () {},
        ),
        _buildActionItem(
          context,
          icon: Icons.car_crash_rounded,
          label: 'Sinistros',
          color: AppTheme.errorColor,
          onTap: () {},
        ),
        _buildActionItem(
          context,
          icon: Icons.support_agent_rounded,
          label: 'Assistência',
          color: const Color(0xFFF4A261),
          onTap: () {},
        ),
        _buildActionItem(
          context,
          icon: Icons.account_balance_wallet_rounded,
          label: 'Carteira',
          color: AppTheme.secondaryColor,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.9),
            const Color(0xFF33BBDD),
            const Color(0xFF66CCEE),
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Image on the right with ShaderMask for smooth left-edge fade
            Positioned(
              right: -10,
              top: 0,
              bottom: 0,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                    ],
                    stops: [0.0, 0.18, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/referral_friends.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Text content on the left
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16, right: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ganhe dinheiro sempre\nque usar seu convite',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Convidar amigo',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoliciesSection(BuildContext context) {
    final policies = [
      _PolicyItem(
        icon: Icons.directions_car_rounded,
        name: 'Seguro Automóvel',
        type: 'Cobertura Total',
        status: 'Ativa',
        color: const Color(0xFF0077B6),
      ),
      _PolicyItem(
        icon: Icons.home_rounded,
        name: 'Seguro Habitação',
        type: 'Cobertura Básica',
        status: 'Ativa',
        color: const Color(0xFF00B4D8),
      ),
      _PolicyItem(
        icon: Icons.health_and_safety_rounded,
        name: 'Seguro de Vida',
        type: 'Plano Familiar',
        status: 'Ativa',
        color: const Color(0xFF48CAE4),
      ),
      _PolicyItem(
        icon: Icons.travel_explore_rounded,
        name: 'Seguro Viagem',
        type: 'Internacional',
        status: 'Pendente',
        color: const Color(0xFF90E0EF),
      ),
    ];

    return Column(
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minhas Apólices',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Liquid Glass Card wrapping all policies
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.6),
                      AppTheme.primaryColor.withValues(alpha: 0.03),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(
                    width: 1.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                child: Stack(
                  children: [
                    // Subtle specular highlight at top-left
                    Positioned(
                      top: -40,
                      left: -40,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.06),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Subtle accent at bottom-right
                    Positioned(
                      bottom: -30,
                      right: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.secondaryColor.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          for (int i = 0; i < policies.length; i++) ...[
                            _buildPolicyListItem(context, policies[i]),
                            if (i < policies.length - 1)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(
                                  height: 1,
                                  color: AppTheme.primaryColor.withValues(alpha: 0.06),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyListItem(BuildContext context, _PolicyItem policy) {
    final isActive = policy.status == 'Ativa';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        splashColor: policy.color.withValues(alpha: 0.05),
        highlightColor: policy.color.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // Glassmorphic icon container
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      policy.color.withValues(alpha: 0.15),
                      policy.color.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: policy.color.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: Icon(
                  policy.icon,
                  color: policy.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Policy info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryColor,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      policy.type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              // Status badge with glass effect
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActive
                        ? [
                            const Color(0xFF22C55E).withValues(alpha: 0.12),
                            const Color(0xFF22C55E).withValues(alpha: 0.06),
                          ]
                        : [
                            const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            const Color(0xFFF59E0B).withValues(alpha: 0.06),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF22C55E).withValues(alpha: 0.2)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  policy.status,
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD97706),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyItem {
  final IconData icon;
  final String name;
  final String type;
  final String status;
  final Color color;

  _PolicyItem({
    required this.icon,
    required this.name,
    required this.type,
    required this.status,
    required this.color,
  });
}
