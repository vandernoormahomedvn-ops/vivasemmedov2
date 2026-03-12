import 'package:flutter/material.dart';
import '../../../../core/theme/glass_container.dart';
import '../../../auth/presentation/pages/phone_input_page.dart';
import '../../domain/services/simulador_service.dart';

class SimulacaoResultPage extends StatefulWidget {
  final String tipoSeguro;
  final String tipoVeiculo;
  final String marca;
  final String modelo;
  final String matricula;
  final double valorEstimado;
  final int numOcupantes;
  final int numVeiculos;

  const SimulacaoResultPage({
    super.key,
    required this.tipoSeguro,
    required this.tipoVeiculo,
    required this.marca,
    required this.modelo,
    required this.matricula,
    required this.valorEstimado,
    required this.numOcupantes,
    required this.numVeiculos,
  });

  @override
  State<SimulacaoResultPage> createState() => _SimulacaoResultPageState();
}

class _SimulacaoResultPageState extends State<SimulacaoResultPage> {
  late Map<String, double> _precos;
  String _selectedPackage = 'Classico'; // Default selection

  @override
  void initState() {
    super.initState();
    _calcularPrecos();
  }

  void _calcularPrecos() {
    if (widget.tipoSeguro == 'RC') {
      _precos = SimuladorService.calcularRC(
        tipoVeiculo: widget.tipoVeiculo,
        numVeiculos: widget.numVeiculos,
        numOcupantes: widget.numOcupantes,
      );
    } else {
      _precos = SimuladorService.calcularDP(
        tipoVeiculo: widget.tipoVeiculo,
        valorVeiculo: widget.valorEstimado,
        numVeiculos: widget.numVeiculos,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRC = widget.tipoSeguro == 'RC';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.secondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sua Cotação',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${isRC ? "Responsabilidade Civil" : "Danos Próprios"} - ${widget.marca} ${widget.modelo}',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Expanded(
                  child: ListView(
                    children: [
                      _buildPackageCard(
                        theme: theme,
                        packageName: 'Basico',
                        description: isRC ? 'Cobertura essencial obrigatória.' : 'Proteção essencial contra danos.',
                        price: _precos['Basico'] ?? 0.0,
                      ),
                      const SizedBox(height: 16),
                      _buildPackageCard(
                        theme: theme,
                        packageName: 'Classico',
                        description: isRC ? 'Maior proteção para ocupantes e terceiros.' : 'Proteção equilibrada com ótimo custo-benefício.',
                        price: _precos['Classico'] ?? 0.0,
                      ),
                      const SizedBox(height: 16),
                      _buildPackageCard(
                        theme: theme,
                        packageName: 'Exclusivo',
                        description: isRC ? 'Cobertura máxima e VIP.' : 'Proteção total e absoluta.',
                        price: _precos['Exclusivo'] ?? 0.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Auth / Contract Flow
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhoneInputPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Avançar com $_selectedPackage',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard({
    required ThemeData theme,
    required String packageName,
    required String description,
    required double price,
  }) {
    final isSelected = _selectedPackage == packageName;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = packageName;
        });
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? theme.primaryColor : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    packageName.toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.primaryColor : theme.colorScheme.secondary,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: theme.primaryColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price.toStringAsFixed(2),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'MZN / ano',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
