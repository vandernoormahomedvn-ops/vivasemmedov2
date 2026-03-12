import 'package:flutter/material.dart';
import '../../../../core/theme/glass_container.dart';
import 'simulacao_form_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEAF4F4),
              Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Viva\nSem Medo',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Escolhe o ramo de seguro ideal para ti.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),
                Expanded(
                  child: ListView(
                    children: [
                      _InsuranceCard(
                        title: 'Seguro Automóvel',
                        description: 'Proteja o seu veículo contra acidentes e roubos.',
                        icon: Icons.directions_car,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SimulacaoFormPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _InsuranceCard(
                        title: 'Seguro Funeral',
                        description: 'Garante tranquilidade à sua família nos momentos difíceis.',
                        icon: Icons.favorite,
                        onTap: () {
                          // TODO: Navigate to simulacao wizard
                        },
                      ),
                      const SizedBox(height: 16),
                      _InsuranceCard(
                        title: 'Seguro Viagem',
                        description: 'Viaje pelo mundo com total segurança.',
                        icon: Icons.flight_takeoff,
                        onTap: () {
                          // TODO: Navigate to simulacao wizard
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsuranceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _InsuranceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
