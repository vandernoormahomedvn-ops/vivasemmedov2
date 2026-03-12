import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/widgets/premium_glass.dart';
import '../../../../core/widgets/liquid_glass_button.dart';
import '../../domain/services/simulador_service.dart';
import '../../domain/services/cotacao_pdf_service.dart';
import '../../../../features/auth/presentation/pages/auth_screen.dart';
import '../../../../features/contratacao/data/models/contratacao_model.dart';
import '../../../../features/contratacao/presentation/pages/contratacao_wizard.dart';

class SimulationWizard extends StatefulWidget {
  const SimulationWizard({super.key});

  @override
  State<SimulationWizard> createState() => _SimulationWizardState();
}

class _SimulationWizardState extends State<SimulationWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final bool _isLoading = false;
  String? _errorMessage;

  // Dynamic total steps: 6 for Automóvel (includes coverage + summary), 4 for Funeral
  int get _totalSteps => _selectedInsuranceType == 'Automóvel' ? 6 : 4;
  bool _isGeneratingPdf = false;

  // Step 1 - Personal Data
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 2 - Insurance Type
  String? _selectedInsuranceType;

  // Step 3 (Automóvel only) - Coverage Type
  String? _selectedCoverageType; // 'RC' or 'DP'

  // Step 3/4 - Vehicle Details (Automóvel)
  String? _selectedVehicleType;
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vehicleValueController = TextEditingController();
  final _occupantsController = TextEditingController(text: '1');

  // Step 3 - Funeral Details
  final _peopleCountController = TextEditingController();
  final _ageController = TextEditingController();

  // Step 4/5 - Quote Result
  String _selectedPackage = 'Classico';
  Map<String, double>? _calculatedPrices;
  final Set<String> _expandedPackages = {};

  // Vehicle type lists (from V1 business rules)
  final List<String> _tiposVeiculoRC = const [
    'Ligeiros, LVD/4X4',
    'Camiões abaixo de 3.5 toneladas',
    'Camiões acima de 3.5 Toneladas',
    'Mini Bus 15 lugares',
    'Autocarros',
    'Atrelados Domésticos',
    'Atrelados Comerciais',
    'Motociclos',
    'Veiculos Especiais',
  ];

  final List<String> _tiposVeiculoDP = const [
    'Ligeiros, LVD/4X4',
    'Camiões abaixo de 3.5 toneladas',
    'Camiões acima de 3.5 Toneladas',
    'Mini Bus 15 lugares',
    'Autocarros',
    'Atrelados domésticos',
    'Atrelados Comerciais',
    'Motociclos',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vehicleValueController.dispose();
    _occupantsController.dispose();
    _peopleCountController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  List<Widget> _buildPages() {
    final pages = <Widget>[
      _buildStep1PersonalData(),
      _buildStep2InsuranceType(),
    ];

    if (_selectedInsuranceType == 'Automóvel') {
      pages.add(_buildStepCoverageType());
      pages.add(_buildStepVehicleDetails());
      pages.add(_buildStepQuoteResult());
      pages.add(_buildStepSummary());
    } else {
      pages.add(_buildStepFuneralDetails());
      pages.add(_buildStepQuoteResult());
    }

    return pages;
  }

  void _nextStep() {
    setState(() => _errorMessage = null);

    // Validation per step
    if (_currentStep == 0) {
      if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
        setState(() => _errorMessage = 'Preencha os campos obrigatórios.');
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedInsuranceType == null) {
        setState(() => _errorMessage = 'Selecione um tipo de seguro.');
        return;
      }
    } else if (_currentStep == 2 && _selectedInsuranceType == 'Automóvel') {
      if (_selectedCoverageType == null) {
        setState(() => _errorMessage = 'Selecione o tipo de cobertura.');
        return;
      }
    } else if (_isVehicleDetailsStep) {
      if (_selectedInsuranceType == 'Automóvel') {
        if (_selectedVehicleType == null) {
          setState(() => _errorMessage = 'Selecione o tipo de veículo.');
          return;
        }
        if (_brandController.text.isEmpty || _modelController.text.isEmpty) {
          setState(() => _errorMessage = 'Preencha a marca e o modelo.');
          return;
        }
        if (_selectedCoverageType == 'DP' &&
            _vehicleValueController.text.isEmpty) {
          setState(
            () => _errorMessage = 'Informe o valor estimado do veículo.',
          );
          return;
        }
      } else {
        // Funeral validation
        if (_peopleCountController.text.isEmpty ||
            _ageController.text.isEmpty) {
          setState(() => _errorMessage = 'Preencha todos os campos.');
          return;
        }
      }
      // Calculate prices before showing quote
      _calculatePrices();
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  bool get _isVehicleDetailsStep {
    if (_selectedInsuranceType == 'Automóvel') {
      return _currentStep == 3;
    }
    return _currentStep == 2; // Funeral details step
  }

  void _calculatePrices() {
    if (_selectedInsuranceType == 'Automóvel' && _selectedVehicleType != null) {
      if (_selectedCoverageType == 'RC') {
        final occupants = int.tryParse(_occupantsController.text) ?? 1;
        _calculatedPrices = SimuladorService.calcularRC(
          tipoVeiculo: _selectedVehicleType!,
          numVeiculos: 1,
          numOcupantes: occupants,
        );
      } else if (_selectedCoverageType == 'DP') {
        final value = double.tryParse(_vehicleValueController.text) ?? 0.0;
        _calculatedPrices = SimuladorService.calcularDP(
          tipoVeiculo: _selectedVehicleType!,
          valorVeiculo: value,
          numVeiculos: 1,
        );
      }
    }
  }

  Future<void> _gerarCotacaoPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final data = CotacaoData(
        nomeCliente: _nameController.text,
        celularCliente: _phoneController.text,
        emailCliente: _emailController.text,
        tipoSeguro: _selectedCoverageType ?? 'RC',
        tipoVeiculo: _selectedVehicleType ?? '',
        marca: _brandController.text,
        modelo: _modelController.text,
        ano: _yearController.text,
        valorViatura: double.tryParse(_vehicleValueController.text),
        numOcupantes: int.tryParse(_occupantsController.text),
        pacoteSelecionado: _selectedPackage,
        premioBasico: _calculatedPrices?['Basico'] ?? 0.0,
        premioClassico: _calculatedPrices?['Classico'] ?? 0.0,
        premioExclusivo: _calculatedPrices?['Exclusivo'] ?? 0.0,
      );
      await CotacaoPdfService.gerarPdf(data);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erro ao gerar PDF: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  void _previousStep() {
    setState(() => _errorMessage = null);
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Simular Seguro',
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),

                // Progress Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: List.generate(_totalSteps, (index) {
                      final active = index <= _currentStep;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            right: index == _totalSteps - 1 ? 0 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) =>
                        setState(() => _currentStep = page),
                    children: _buildPages(),
                  ),
                ),

                // Bottom Actions
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_currentStep < _totalSteps - 1)
                        LiquidGlassButton(onTap: _nextStep, label: 'Continuar')
                      else
                        Column(
                          children: [
                            LiquidGlassButton(
                              isLoading: _isLoading,
                              onTap: () {
                                // Build ContratacaoModel with all simulation data
                                final contratacao = ContratacaoModel(
                                  nomeCliente: _nameController.text,
                                  telefoneCliente: _phoneController.text,
                                  emailCliente: _emailController.text,
                                  tipoSeguro: _selectedInsuranceType ?? 'Automóvel',
                                  tipoCobertura: _selectedCoverageType ?? 'RC',
                                  tipoVeiculo: _selectedVehicleType,
                                  marca: _brandController.text,
                                  modelo: _modelController.text,
                                  ano: _yearController.text,
                                  valorVeiculo: double.tryParse(_vehicleValueController.text),
                                  numOcupantes: int.tryParse(_occupantsController.text),
                                  numPessoas: int.tryParse(_peopleCountController.text),
                                  idadeMedia: int.tryParse(_ageController.text),
                                  pacoteSelecionado: _selectedPackage,
                                  premioTotal: _calculatedPrices?[_selectedPackage] ?? 0.0,
                                  precosPerPackage: _calculatedPrices ?? {},
                                );

                                // Check if user is authenticated
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  // User is logged in → go directly to ContratacaoWizard
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ContratacaoWizard(
                                        contratacao: contratacao,
                                      ),
                                    ),
                                  );
                                } else {
                                  // User not logged in → go to AuthScreen first
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AuthScreen(initialIsRegisterMode: true),
                                    ),
                                    (route) => false,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Crie uma conta para contratar o seu seguro.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              },
                              label: 'Contratar seguro',
                            ),
                            if (_selectedInsuranceType == 'Automóvel') ...[
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: _isGeneratingPdf ? null : _gerarCotacaoPdf,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: const Size(double.infinity, 56),
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isGeneratingPdf
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.picture_as_pdf_outlined, 
                                            color: Theme.of(context).colorScheme.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Baixar Cotação PDF',
                                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 1: Personal Data ───────────────────────────────────────

  Widget _buildStep1PersonalData() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Para começarmos,',
            style: Theme.of(context).textTheme.headlineLarge!,
          ),
          const SizedBox(height: 8),
          Text(
            'diga-nos com quem estamos a falar.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          _buildInput(
            controller: _nameController,
            label: 'Nome Completo',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildInput(
            controller: _phoneController,
            label: 'Telemóvel',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildInput(
            controller: _emailController,
            label: 'E-mail (Opcional)',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  // ─── STEP 2: Insurance Type (Automóvel / Funeral) ────────────────

  Widget _buildStep2InsuranceType() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qual seguro?',
            style: Theme.of(context).textTheme.headlineLarge!,
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha o ramo que deseja simular hoje.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildSelectionCard(
                  value: 'Automóvel',
                  selectedValue: _selectedInsuranceType,
                  icon: Icons.directions_car_outlined,
                  description: 'Proteção garantida\npara o seu veículo',
                  gradientColors: const [Color(0xFF00B4D8), Color(0xFF0F2C59)],
                  onTap: () {
                    setState(() {
                      _selectedInsuranceType = 'Automóvel';
                      // Reset coverage when switching insurance type
                      _selectedCoverageType = null;
                      _selectedVehicleType = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectionCard(
                  value: 'Funeral',
                  selectedValue: _selectedInsuranceType,
                  icon: Icons.spa_outlined,
                  description: 'Tranquilidade e\napoio à família',
                  gradientColors: const [Color(0xFF6C63FF), Color(0xFF2A2D34)],
                  onTap: () {
                    setState(() {
                      _selectedInsuranceType = 'Funeral';
                      _selectedCoverageType = null;
                      _selectedVehicleType = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STEP 3 (Automóvel): Coverage Type (RC / DP) ─────────────────

  Widget _buildStepCoverageType() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de Cobertura',
            style: Theme.of(context).textTheme.headlineLarge!,
          ),
          const SizedBox(height: 8),
          Text(
            'Que tipo de proteção pretende para o seu veículo?',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          _buildCoverageCard(
            type: 'RC',
            title: 'Responsabilidade Civil',
            icon: Icons.shield_outlined,
            description:
                'Cobre danos causados a terceiros em caso de acidente. É o seguro obrigatório por lei em Moçambique.',
            highlights: const [
              'Obrigatório por lei',
              'Cobre danos a terceiros',
              'Sem valor mínimo do veículo',
            ],
            gradientColors: const [Color(0xFF00B4D8), Color(0xFF0F2C59)],
          ),
          const SizedBox(height: 16),
          _buildCoverageCard(
            type: 'DP',
            title: 'Danos Próprios',
            icon: Icons.car_crash_outlined,
            description:
                'Protege o seu próprio veículo contra colisão, roubo, incêndio e outros danos. Inclui cobertura RC.',
            highlights: const [
              'Proteção completa do veículo',
              'Colisão, roubo e incêndio',
              'Inclui Responsabilidade Civil',
            ],
            gradientColors: const [Color(0xFFE6A817), Color(0xFF0F2C59)],
          ),
        ],
      ),
    );
  }

  Widget _buildCoverageCard({
    required String type,
    required String title,
    required IconData icon,
    required String description,
    required List<String> highlights,
    required List<Color> gradientColors,
  }) {
    final isSelected = _selectedCoverageType == type;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCoverageType = type;
          _selectedVehicleType = null; // Reset vehicle type on coverage change
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isSelected ? Colors.white : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? Colors.white
                      : colorScheme.outline.withValues(alpha: 0.3),
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ...highlights.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STEP: Vehicle Details (Automóvel) ────────────────────────────

  Widget _buildStepVehicleDetails() {
    final isDP = _selectedCoverageType == 'DP';
    final isRC = _selectedCoverageType == 'RC';
    final tiposVeiculo = isRC ? _tiposVeiculoRC : _tiposVeiculoDP;
    final needsOccupants =
        isRC &&
        (_selectedVehicleType == 'Mini Bus 15 lugares' ||
            _selectedVehicleType == 'Autocarros');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes do Veículo',
            style: Theme.of(context).textTheme.headlineLarge!,
          ),
          const SizedBox(height: 8),
          Text(
            isDP
                ? 'Informações sobre o veículo e valor estimado.'
                : 'Informações sobre o veículo a segurar.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Vehicle Type Dropdown
          _buildDropdown(
            label: 'Tipo de Veículo',
            icon: Icons.local_shipping_outlined,
            value: _selectedVehicleType,
            items: tiposVeiculo,
            onChanged: (value) {
              setState(() => _selectedVehicleType = value);
            },
          ),
          const SizedBox(height: 16),

          _buildInput(
            controller: _brandController,
            label: 'Marca (Ex: Toyota)',
            icon: Icons.car_rental,
          ),
          const SizedBox(height: 16),
          _buildInput(
            controller: _modelController,
            label: 'Modelo (Ex: Corolla)',
            icon: Icons.directions_car,
          ),
          const SizedBox(height: 16),
          _buildInput(
            controller: _yearController,
            label: 'Ano de Fabrico (Ex: 2020)',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
          ),

          // DP: Vehicle value
          if (isDP) ...[
            const SizedBox(height: 16),
            _buildInput(
              controller: _vehicleValueController,
              label: 'Valor Estimado do Veículo (MZN)',
              icon: Icons.monetization_on_outlined,
              keyboardType: TextInputType.number,
            ),
          ],

          // RC: Occupants (only for Mini Bus / Autocarros)
          if (needsOccupants) ...[
            const SizedBox(height: 16),
            _buildInput(
              controller: _occupantsController,
              label: 'Número de Ocupantes',
              icon: Icons.people_outline,
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      ),
    );
  }

  // ─── STEP: Funeral Details ────────────────────────────────────────

  Widget _buildStepFuneralDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalhes', style: Theme.of(context).textTheme.headlineLarge!),
          const SizedBox(height: 8),
          Text(
            'Passe os detalhes para a simulação do Funeral.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          _buildInput(
            controller: _peopleCountController,
            label: 'A quantas pessoas se destina?',
            icon: Icons.group_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInput(
            controller: _ageController,
            label: 'Sua Idade (Ex: 35)',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  // ─── STEP: Quote Result ───────────────────────────────────────────

  Widget _buildStepQuoteResult() {
    final isAuto = _selectedInsuranceType == 'Automóvel';
    final isRC = _selectedCoverageType == 'RC';

    // For Funeral, show mock data (unchanged)
    if (!isAuto) {
      return _buildFuneralQuoteResult();
    }

    // For Automóvel, show 3 calculated packages
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sua Cotação',
            style: Theme.of(context).textTheme.headlineLarge!,
          ),
          const SizedBox(height: 8),
          Text(
            '${isRC ? "Responsabilidade Civil" : "Danos Próprios"} — ${_brandController.text} ${_modelController.text}',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildPackageOption(
            name: 'Básico',
            key: 'Basico',
            description: isRC
                ? 'Cobertura essencial obrigatória. Limite RC: 3.000.000 MT'
                : 'Proteção essencial contra danos. Capital: 8.000.000 MT',
            price: _calculatedPrices?['Basico'] ?? 0.0,
          ),
          const SizedBox(height: 12),
          _buildPackageOption(
            name: 'Clássico',
            key: 'Classico',
            description: isRC
                ? 'Proteção equilibrada para ocupantes e terceiros. Limite RC: 4.000.000 MT'
                : 'Cobertura equilibrada com ótimo custo-benefício. Capital: 8.000.000 MT',
            price: _calculatedPrices?['Classico'] ?? 0.0,
            recommended: true,
          ),
          const SizedBox(height: 12),
          _buildPackageOption(
            name: 'Exclusivo',
            key: 'Exclusivo',
            description: isRC
                ? 'Cobertura máxima e premium. Limite RC: 5.400.000 MT'
                : 'Proteção total e absoluta. Capital: 8.000.000 MT',
            price: _calculatedPrices?['Exclusivo'] ?? 0.0,
          ),
        ],
      ),
    );
  }

  Widget _buildFuneralQuoteResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sua Cotação',
            style: Theme.of(context).textTheme.headlineLarge!,
          ),
          const SizedBox(height: 8),
          Text(
            'Veja o valor estimado do seu prémio.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          PremiumGlass(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Prémio Anual',
                  style: Theme.of(context).textTheme.bodyMedium!,
                ),
                Text(
                  '12.500,00 MT',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cobertura',
                      style: Theme.of(context).textTheme.bodySmall!,
                    ),
                    Text(
                      'Seguro Funeral',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pessoas',
                      style: Theme.of(context).textTheme.bodySmall!,
                    ),
                    Text(
                      _peopleCountController.text,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP: Summary / Review ──────────────────────────────────────

  Widget _buildStepSummary() {
    final colorScheme = Theme.of(context).colorScheme;
    final isRC = _selectedCoverageType == 'RC';
    final isDP = _selectedCoverageType == 'DP';
    final selectedPrice = _calculatedPrices?[_selectedPackage] ?? 0.0;

    String pacoteLabel;
    switch (_selectedPackage) {
      case 'Basico':
        pacoteLabel = 'Básico';
        break;
      case 'Exclusivo':
        pacoteLabel = 'Exclusivo';
        break;
      default:
        pacoteLabel = 'Clássico';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo da Cotação',
            style: Theme.of(context).textTheme.headlineLarge!,
          ),
          const SizedBox(height: 8),
          Text(
            'Confirme os dados antes de gerar a cotação.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),

          // Client Info
          _buildSummarySection(
            title: 'Dados Pessoais',
            icon: Icons.person_outline,
            color: colorScheme.primary,
            items: [
              _summaryItem('Nome', _nameController.text),
              _summaryItem('Telemóvel', _phoneController.text),
              if (_emailController.text.isNotEmpty)
                _summaryItem('E-mail', _emailController.text),
            ],
          ),
          const SizedBox(height: 16),

          // Vehicle Info
          _buildSummarySection(
            title: 'Detalhes do Veículo',
            icon: Icons.directions_car_outlined,
            color: const Color(0xFF00B4D8),
            items: [
              _summaryItem('Cobertura', isRC ? 'Responsabilidade Civil' : 'Danos Próprios'),
              _summaryItem('Tipo de Veículo', _selectedVehicleType ?? '-'),
              _summaryItem('Marca', _brandController.text),
              _summaryItem('Modelo', _modelController.text),
              if (_yearController.text.isNotEmpty)
                _summaryItem('Ano', _yearController.text),
              if (isDP && _vehicleValueController.text.isNotEmpty)
                _summaryItem('Valor Estimado', '${_formatPrice(double.tryParse(_vehicleValueController.text) ?? 0)} MT'),
              if (isRC &&
                  (_selectedVehicleType == 'Mini Bus 15 lugares' ||
                      _selectedVehicleType == 'Autocarros'))
                _summaryItem('Ocupantes', _occupantsController.text),
            ],
          ),
          const SizedBox(height: 16),

          // Selected Package
          _buildSummarySection(
            title: 'Pacote Selecionado',
            icon: Icons.verified_outlined,
            color: const Color(0xFFE6A817),
            items: [
              _summaryItem('Pacote', pacoteLabel),
              _summaryItem('Prémio Anual', '${_formatPrice(selectedPrice)} MT'),
              if (isRC)
                _summaryItem('Limite RC', _selectedPackage == 'Basico'
                    ? '3.000.000 MT'
                    : _selectedPackage == 'Classico'
                        ? '4.000.000 MT'
                        : '5.400.000 MT'),
              if (isDP)
                _summaryItem('Capital Seguro', '8.000.000 MT'),
            ],
          ),
          const SizedBox(height: 16),

          // Coverages of selected package
          _buildSummarySection(
            title: 'Coberturas ($pacoteLabel)',
            icon: Icons.shield_outlined,
            color: const Color(0xFF6C63FF),
            items: [
              ..._getCoberturasBasicas(_selectedPackage)
                  .map((c) => _summaryItem(c['titulo']!, c['descricao']!)),
              ..._getCoberturasAdicionais(_selectedPackage)
                  .map((c) => _summaryItem(c['titulo']!, c['descricao']!)),
            ],
          ),

          // Deductibles (DP only)
          if (isDP) ...[
            const SizedBox(height: 16),
            _buildSummarySection(
              title: 'Franquias ($pacoteLabel)',
              icon: Icons.receipt_long_outlined,
              color: Colors.orange,
              items: _getFranquias(_selectedPackage)
                  .map((f) => _summaryItem(f['evento']!, f['valor']!))
                  .toList(),
            ),
          ],

          // All 3 premiums comparison
          const SizedBox(height: 16),
          _buildSummarySection(
            title: 'Comparação de Prémios',
            icon: Icons.compare_arrows,
            color: colorScheme.primary,
            items: [
              _summaryItem('Básico', '${_formatPrice(_calculatedPrices?['Basico'] ?? 0)} MT/ano'),
              _summaryItem('Clássico', '${_formatPrice(_calculatedPrices?['Classico'] ?? 0)} MT/ano'),
              _summaryItem('Exclusivo', '${_formatPrice(_calculatedPrices?['Exclusivo'] ?? 0)} MT/ano'),
            ],
          ),

          const SizedBox(height: 24),
          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'A cotação PDF inclui os 3 pacotes para comparação. Válida por 30 dias.',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.3,
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

  Widget _buildSummarySection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> items,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ─── COVERAGE & DEDUCTIBLE DATA (from V1 business rules) ───────

  List<Map<String, String>> _getCoberturasBasicas(String pacoteKey) {
    final isAtrelado =
        _selectedVehicleType != null &&
        (_selectedVehicleType!.contains('Atrelados'));

    switch (pacoteKey) {
      case 'Basico':
        final list = [
          {'titulo': 'Danos Materiais', 'descricao': 'Até MT 100.000'},
          {'titulo': 'Danos Corporais', 'descricao': 'Até MT 50.000'},
          {'titulo': 'Assistência 24h', 'descricao': 'Guincho e socorro'},
        ];
        if (isAtrelado) {
          list.removeWhere((c) => c['titulo'] == 'Danos Corporais');
        }
        return list;
      case 'Classico':
        final list = [
          {'titulo': 'Danos Materiais', 'descricao': 'Até MT 250.000'},
          {'titulo': 'Danos Corporais', 'descricao': 'Até MT 100.000'},
          {'titulo': 'Assistência 24h', 'descricao': 'Guincho e socorro'},
          {'titulo': 'Furto ou Roubo', 'descricao': 'Cobertura total'},
        ];
        if (isAtrelado) {
          list.removeWhere((c) => c['titulo'] == 'Danos Corporais');
        }
        return list;
      case 'Exclusivo':
        final list = [
          {'titulo': 'Danos Materiais', 'descricao': 'Até MT 500.000'},
          {'titulo': 'Danos Corporais', 'descricao': 'Até MT 200.000'},
          {
            'titulo': 'Assistência 24h',
            'descricao': 'Guincho e socorro premium',
          },
          {'titulo': 'Furto ou Roubo', 'descricao': 'Cobertura total'},
          {'titulo': 'Incêndio', 'descricao': 'Cobertura total'},
        ];
        if (isAtrelado) {
          list.removeWhere((c) => c['titulo'] == 'Danos Corporais');
        }
        return list;
      default:
        return [];
    }
  }

  List<Map<String, String>> _getCoberturasAdicionais(String pacoteKey) {
    final isAtrelado =
        _selectedVehicleType != null &&
        (_selectedVehicleType!.contains('Atrelados'));

    switch (pacoteKey) {
      case 'Basico':
        return [
          {'titulo': 'Proteção de Terceiros', 'descricao': 'Até MT 200.000'},
        ];
      case 'Classico':
        final list = [
          {'titulo': 'Carro Reserva', 'descricao': '15 dias por sinistro'},
          {'titulo': 'Vidros', 'descricao': 'Sem franquia'},
          {'titulo': 'Proteção de Terceiros', 'descricao': 'Até MT 500.000'},
        ];
        if (isAtrelado) {
          list.removeWhere(
            (c) => c['titulo'] == 'Vidros' || c['titulo'] == 'Carro Reserva',
          );
        }
        return list;
      case 'Exclusivo':
        final list = [
          {'titulo': 'Carro Reserva', 'descricao': '30 dias por sinistro'},
          {'titulo': 'Vidros', 'descricao': 'Sem franquia'},
          {'titulo': 'Proteção de Terceiros', 'descricao': 'Até MT 1.000.000'},
          {'titulo': 'Equipamento de Som', 'descricao': 'Cobertura total'},
        ];
        if (isAtrelado) {
          list.removeWhere(
            (c) => c['titulo'] == 'Vidros' || c['titulo'] == 'Carro Reserva',
          );
        }
        return list;
      default:
        return [];
    }
  }

  List<Map<String, String>> _getFranquias(String pacoteKey) {
    // Franquias only apply to DP
    if (_selectedCoverageType != 'DP') return [];

    final veiculo = _selectedVehicleType ?? '';

    switch (pacoteKey) {
      case 'Basico':
        if (veiculo == 'Ligeiros, LVD/4X4') {
          return [
            {
              'evento': 'Choque, Colisão ou Capotamento',
              'valor': '10% do sinistro, mín. MT 12.400',
            },
            {'evento': 'Furto ou Roubo', 'valor': '20% do valor da viatura'},
            {
              'evento': 'Quebra Isolada de Vidros',
              'valor': '15% dos danos, mín. MT 2.800',
            },
            {
              'evento': 'Equipamento de Som',
              'valor': '10% dos danos, mín. MT 2.800',
            },
          ];
        } else if (veiculo == 'Camiões abaixo de 3.5 toneladas') {
          return [
            {
              'evento': 'Choque, Colisão ou Capotamento',
              'valor': '10% do sinistro, mín. MT 16.000',
            },
            {'evento': 'Furto ou Roubo', 'valor': '20% do valor da viatura'},
            {
              'evento': 'Quebra Isolada de Vidros',
              'valor': '15% dos danos, mín. MT 2.800',
            },
            {
              'evento': 'Equipamento de Som',
              'valor': '10% dos danos, mín. MT 2.800',
            },
          ];
        } else if (veiculo.contains('Atrelados')) {
          return [
            {
              'evento': 'Choque, Colisão ou Capotamento',
              'valor': '10% do sinistro, mín. MT 8.000',
            },
            {'evento': 'Furto ou Roubo', 'valor': '20% do valor da viatura'},
            {
              'evento': 'Furto de peças e acessórios',
              'valor': '15% dos danos, mín. MT 2.800',
            },
          ];
        }
        // Default for other vehicle types
        return [
          {
            'evento': 'Choque, Colisão ou Capotamento',
            'valor': '10% do sinistro',
          },
          {'evento': 'Furto ou Roubo', 'valor': '20% do valor da viatura'},
        ];
      case 'Classico':
        return [
          {
            'evento': 'Choque, Colisão ou Capotamento',
            'valor': '7.5% do sinistro',
          },
          {'evento': 'Furto ou Roubo', 'valor': '15% do valor da viatura'},
          {'evento': 'Quebra Isolada de Vidros', 'valor': 'Sem franquia'},
        ];
      case 'Exclusivo':
        return [
          {
            'evento': 'Choque, Colisão ou Capotamento',
            'valor': '5% do sinistro',
          },
          {'evento': 'Furto ou Roubo', 'valor': '10% do valor da viatura'},
          {'evento': 'Quebra Isolada de Vidros', 'valor': 'Sem franquia'},
          {'evento': 'Equipamento de Som', 'valor': 'Sem franquia'},
        ];
      default:
        return [];
    }
  }

  Widget _buildPackageOption({
    required String name,
    required String key,
    required String description,
    required double price,
    bool recommended = false,
  }) {
    final isSelected = _selectedPackage == key;
    final isExpanded = _expandedPackages.contains(key);
    final colorScheme = Theme.of(context).colorScheme;

    final coberturasBasicas = _getCoberturasBasicas(key);
    final coberturasAdicionais = _getCoberturasAdicionais(key);
    final franquias = _getFranquias(key);
    final isDP = _selectedCoverageType == 'DP';

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
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
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (recommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Recomendado',
                          style: Theme.of(context).textTheme.labelSmall!
                              .copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(price),
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    'MT / ano',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),

            // Expandable details toggle
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedPackages.remove(key);
                  } else {
                    _expandedPackages.add(key);
                  }
                });
              },
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isExpanded
                        ? 'Ocultar detalhes'
                        : 'Ver coberturas e franquias',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Expandable content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coberturas Básicas
                    _buildDetailSection(
                      title: 'Coberturas Básicas',
                      icon: Icons.verified_outlined,
                      items: coberturasBasicas
                          .map((c) => '${c['titulo']}: ${c['descricao']}')
                          .toList(),
                      color: colorScheme.primary,
                    ),

                    const SizedBox(height: 12),

                    // Coberturas Adicionais
                    _buildDetailSection(
                      title: 'Coberturas Adicionais',
                      icon: Icons.add_circle_outline,
                      items: coberturasAdicionais
                          .map((c) => '${c['titulo']}: ${c['descricao']}')
                          .toList(),
                      color: const Color(0xFF6C63FF),
                    ),

                    // Franquias (only for DP)
                    if (isDP && franquias.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailSection(
                        title: 'Franquias',
                        icon: Icons.receipt_long_outlined,
                        items: franquias
                            .map((f) => '${f['evento']}: ${f['valor']}')
                            .toList(),
                        color: const Color(0xFFE6A817),
                      ),
                    ],
                  ],
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Add thousand separators
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }
    return '$buffer,$decPart';
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────────────

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge!,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      isExpanded: true,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSelectionCard({
    required String value,
    required String? selectedValue,
    required IconData icon,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedValue == value;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 230,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isSelected ? Colors.white : colorScheme.primary,
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? Colors.white
                      : colorScheme.outline.withValues(alpha: 0.3),
                  size: 28,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.9)
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
