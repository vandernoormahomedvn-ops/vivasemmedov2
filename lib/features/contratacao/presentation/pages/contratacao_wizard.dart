import 'package:flutter/material.dart';
import '../../../../core/widgets/premium_glass.dart';
import '../../../../core/widgets/liquid_glass_button.dart';
import '../../data/models/contratacao_model.dart';
import '../../data/models/apolice_model.dart';
import '../../data/repositories/apolice_repository.dart';
import '../../data/services/mpesa_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// 6-step insurance contracting wizard with Flexpress-inspired UX.
///
/// Steps:
/// 1. Resumo da Cotação (Quote summary)
/// 2. Documentos Pessoais (Personal documents upload)
/// 3. Fotos do Veículo (Vehicle photos — Automóvel only)
/// 4. Método de Pagamento (Payment method selection)
/// 5. Checkout & Resumo Final (Checkout summary)
/// 6. Sucesso (Success screen)
class ContratacaoWizard extends StatefulWidget {
  final ContratacaoModel contratacao;

  const ContratacaoWizard({super.key, required this.contratacao});

  @override
  State<ContratacaoWizard> createState() => _ContratacaoWizardState();
}

class _ContratacaoWizardState extends State<ContratacaoWizard>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentStep = 0;
  String? _errorMessage;
  bool _isProcessing = false;
  String? _apoliceNumero;
  String? _apoliceId;

  late ContratacaoModel _data;
  final _phonePagamentoController = TextEditingController();

  // Dynamic total steps: 6 for Automóvel, 5 for Funeral (skip vehicle photos)
  int get _totalSteps => _data.tipoSeguro == 'Automóvel' ? 6 : 5;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _data = widget.contratacao;
    _pageController = PageController();
    _phonePagamentoController.text = _data.telefoneCliente;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phonePagamentoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  List<Widget> _buildPages() {
    final pages = <Widget>[
      _buildStepQuoteSummary(),
      _buildStepDocuments(),
    ];

    if (_data.tipoSeguro == 'Automóvel') {
      pages.add(_buildStepVehiclePhotos());
    }

    pages.addAll([
      _buildStepPaymentMethod(),
      _buildStepCheckout(),
      _buildStepSuccess(),
    ]);

    return pages;
  }

  void _nextStep() {
    setState(() => _errorMessage = null);

    // Validate current step
    if (!_validateCurrentStep()) return;

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  bool _validateCurrentStep() {
    // Step validation based on actual step index
    final actualStep = _getActualStep(_currentStep);

    switch (actualStep) {
      case 'quote':
        return true; // Quote summary is read-only
      case 'documents':
        // Documents are optional for now (AI validation is future)
        return true;
      case 'photos':
        // Photos are optional for now
        return true;
      case 'payment':
        if (_data.metodoPagamento.isEmpty) {
          setState(
            () => _errorMessage = 'Selecione um método de pagamento.',
          );
          return false;
        }
        if (_data.metodoPagamento == 'M-Pesa' ||
            _data.metodoPagamento == 'E-Mola') {
          final phone = _phonePagamentoController.text.trim();
          if (phone.isEmpty || phone.length < 9) {
            setState(
              () => _errorMessage = 'Introduza o número de telemóvel válido.',
            );
            return false;
          }
          _data.telefonePagamento = phone;
        }
        return true;
      case 'checkout':
        if (!_data.aceitouTermos) {
          setState(
            () => _errorMessage = 'Aceite os termos e condições para continuar.',
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  String _getActualStep(int index) {
    if (_data.tipoSeguro == 'Automóvel') {
      return ['quote', 'documents', 'photos', 'payment', 'checkout', 'success'][index];
    }
    return ['quote', 'documents', 'payment', 'checkout', 'success'][index];
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

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final authRepo = AuthRepository();
      final user = authRepo.currentUser;

      if (user == null) {
        setState(() {
          _errorMessage = 'Sessão expirada. Faça login novamente.';
          _isProcessing = false;
        });
        return;
      }

      // 1. Generate apólice number
      final apoliceRepo = ApoliceRepository();
      final numero = await apoliceRepo.getNextApoliceNumber();

      // 2. Create apólice in Firestore (status: pendente)
      final apolice = ApoliceModel(
        userId: user.uid,
        numero: numero,
        tipo: _data.tipoCobertura.isNotEmpty ? _data.tipoCobertura : 'Funeral',
        pacote: _data.pacoteSelecionado,
        premio: _data.premioTotal,
        status: 'pendente',
        nomeCliente: _data.nomeCliente,
        telefoneCliente: _data.telefoneCliente,
        emailCliente: _data.emailCliente,
        tipoVeiculo: _data.tipoVeiculo,
        marca: _data.marca,
        modelo: _data.modelo,
        ano: _data.ano,
        valorVeiculo: _data.valorVeiculo,
        numOcupantes: _data.numOcupantes,
        numPessoas: _data.numPessoas,
        idadeMedia: _data.idadeMedia,
        coberturas: _data.coberturas,
        metodoPagamento: _data.metodoPagamento,
      );

      final apoliceId = await apoliceRepo.createApolice(apolice);

      // 3. Process M-Pesa payment
      if (_data.metodoPagamento == 'M-Pesa' ||
          _data.metodoPagamento == 'E-Mola') {
        final mpesa = MpesaService();
        final phone = _data.telefonePagamento ?? _data.telefoneCliente;
        final result = await mpesa.initiatePayment(
          amount: _data.premioTotal.toStringAsFixed(2),
          phoneNumber: phone.startsWith('258') ? phone : '258$phone',
          reference: numero,
        );

        if (result.success) {
          await apoliceRepo.updatePayment(
            apoliceId: apoliceId,
            transactionId: result.transactionId,
            pagamentoStatus: 'confirmado',
          );
        } else {
          await apoliceRepo.updatePayment(
            apoliceId: apoliceId,
            transactionId: '',
            pagamentoStatus: 'pendente',
          );
        }
      }

      setState(() {
        _apoliceNumero = numero;
        _apoliceId = apoliceId;
        _isProcessing = false;
      });

      // Navigate to success step
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao processar pagamento: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSuccessStep = _getActualStep(_currentStep) == 'success';

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.15),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (hidden on success)
                  if (!isSuccessStep) ...[
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
                            'Contratar Seguro',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                    ),

                    // Animated Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        children: List.generate(_totalSteps, (index) {
                          final active = index <= _currentStep;
                          return Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 4,
                              margin: EdgeInsets.only(
                                right: index == _totalSteps - 1 ? 0 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? colorScheme.primary
                                    : colorScheme.onSurface
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],

                  // Page Content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) =>
                          setState(() => _currentStep = page),
                      children: _buildPages(),
                    ),
                  ),

                  // Bottom Action (hidden on success)
                  if (!isSuccessStep)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 20, color: colorScheme.error),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: colorScheme.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (_getActualStep(_currentStep) == 'checkout')
                            LiquidGlassButton(
                              isLoading: _isProcessing,
                              onTap: _processPayment,
                              label: 'Confirmar e Pagar',
                            )
                          else
                            LiquidGlassButton(
                              onTap: _nextStep,
                              label: 'Continuar',
                            ),
                        ],
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

  // ═══════════════════════════════════════════════════════════════════
  // STEP 1: Quote Summary
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStepQuoteSummary() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo da Cotação',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Confirme os detalhes antes de prosseguir.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),

          // Insurance type card
          _buildGlassInfoCard(
            icon: _data.tipoSeguro == 'Automóvel'
                ? Icons.directions_car_outlined
                : Icons.spa_outlined,
            title: _data.tipoSeguroDisplay,
            subtitle: 'Pacote ${_data.pacoteSelecionado}',
            gradientColors: _data.tipoSeguro == 'Automóvel'
                ? [const Color(0xFF00B4D8), const Color(0xFF0F2C59)]
                : [const Color(0xFF6C63FF), const Color(0xFF2A2D34)],
          ),
          const SizedBox(height: 16),

          // Price card
          PremiumGlass(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prémio Anual',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                    Text(
                      '${_data.premioTotal.toStringAsFixed(2)} MZN',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // All 3 package prices for comparison
                ...(_data.precosPerPackage.entries.map((entry) {
                  final isSelected = entry.key == _data.pacoteSelecionado;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _data = ContratacaoModel(
                            nomeCliente: _data.nomeCliente,
                            telefoneCliente: _data.telefoneCliente,
                            emailCliente: _data.emailCliente,
                            tipoSeguro: _data.tipoSeguro,
                            tipoCobertura: _data.tipoCobertura,
                            tipoVeiculo: _data.tipoVeiculo,
                            marca: _data.marca,
                            modelo: _data.modelo,
                            ano: _data.ano,
                            valorVeiculo: _data.valorVeiculo,
                            numOcupantes: _data.numOcupantes,
                            numPessoas: _data.numPessoas,
                            idadeMedia: _data.idadeMedia,
                            pacoteSelecionado: entry.key,
                            premioTotal: entry.value,
                            precosPerPackage: _data.precosPerPackage,
                            coberturas: _data.coberturas,
                          );
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 20,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline
                                          .withValues(alpha: 0.3),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  entry.key,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            Text(
                              '${entry.value.toStringAsFixed(2)} MZN',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Vehicle / Funeral details
          if (_data.tipoSeguro == 'Automóvel')
            PremiumGlass(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dados do Veículo',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Tipo', _data.tipoVeiculo ?? '—'),
                  _buildDetailRow('Marca', _data.marca ?? '—'),
                  _buildDetailRow('Modelo', _data.modelo ?? '—'),
                  _buildDetailRow('Ano', _data.ano ?? '—'),
                  if (_data.valorVeiculo != null)
                    _buildDetailRow(
                      'Valor',
                      '${_data.valorVeiculo!.toStringAsFixed(2)} MZN',
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 2: Document Upload
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStepDocuments() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documentos',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Envie o seu documento de identificação.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pode avançar sem enviar agora. Os documentos serão solicitados antes da activação.',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildDocumentUploadCard(
            title: 'Bilhete de Identidade (BI)',
            subtitle: 'Frente e verso do BI',
            icon: Icons.badge_outlined,
            hasFile: _data.documentoBiPath != null,
            onTap: () {
              // TODO: Implement image picker
              setState(() => _data.documentoBiPath = 'placeholder_bi.jpg');
            },
          ),
          const SizedBox(height: 16),

          _buildDocumentUploadCard(
            title: 'Carta de Condução',
            subtitle: 'Apenas para seguro automóvel',
            icon: Icons.credit_card_outlined,
            hasFile: _data.documentoCartaPath != null,
            onTap: () {
              setState(
                () => _data.documentoCartaPath = 'placeholder_carta.jpg',
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 3: Vehicle Photos (Automóvel only)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStepVehiclePhotos() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fotos do Veículo',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Fotografe o veículo nos 4 ângulos.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'As fotos podem ser enviadas posteriormente para activação da apólice.',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2x2 Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildPhotoCard(
                label: 'Frente',
                icon: Icons.directions_car,
                hasPhoto: _data.fotoFrentePath != null,
                onTap: () =>
                    setState(() => _data.fotoFrentePath = 'frente.jpg'),
              ),
              _buildPhotoCard(
                label: 'Traseira',
                icon: Icons.directions_car,
                hasPhoto: _data.fotoTraseiraPath != null,
                onTap: () =>
                    setState(() => _data.fotoTraseiraPath = 'traseira.jpg'),
              ),
              _buildPhotoCard(
                label: 'Lateral Esq.',
                icon: Icons.directions_car,
                hasPhoto: _data.fotoLateralEsqPath != null,
                onTap: () => setState(
                    () => _data.fotoLateralEsqPath = 'lateral_esq.jpg'),
              ),
              _buildPhotoCard(
                label: 'Lateral Dir.',
                icon: Icons.directions_car,
                hasPhoto: _data.fotoLateralDirPath != null,
                onTap: () => setState(
                    () => _data.fotoLateralDirPath = 'lateral_dir.jpg'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 4: Payment Method
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStepPaymentMethod() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pagamento',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Como deseja efectuar o pagamento?',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),

          _buildPaymentMethodCard(
            name: 'M-Pesa',
            icon: Icons.phone_android,
            description: 'Pagamento via M-Pesa (Vodacom)',
            gradientColors: [const Color(0xFFE60000), const Color(0xFF8B0000)],
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodCard(
            name: 'E-Mola',
            icon: Icons.phone_android,
            description: 'Pagamento via E-Mola (Movitel)',
            gradientColors: [const Color(0xFF00A651), const Color(0xFF005C2E)],
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodCard(
            name: 'VISA',
            icon: Icons.credit_card,
            description: 'Cartão de crédito/débito (em breve)',
            gradientColors: [const Color(0xFF1A1F71), const Color(0xFF0D1B4A)],
            enabled: false,
          ),

          // Phone number field (M-Pesa / E-Mola)
          if (_data.metodoPagamento == 'M-Pesa' ||
              _data.metodoPagamento == 'E-Mola') ...[
            const SizedBox(height: 24),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: PremiumGlass(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Número de Telemóvel',
                      style:
                          Theme.of(context).textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'O pedido de pagamento será enviado para este número.',
                      style:
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phonePagamentoController,
                      keyboardType: TextInputType.phone,
                      style: Theme.of(context).textTheme.titleMedium,
                      decoration: InputDecoration(
                        prefixText: '+258 ',
                        prefixStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                        hintText: '84 XXX XXXX',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color:
                                colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor:
                            colorScheme.surface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 5: Checkout & Final Summary
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStepCheckout() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirmação',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Revise todos os dados antes de confirmar.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),

          // Checkout summary card
          PremiumGlass(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildCheckoutRow(
                  'Seguro',
                  _data.tipoSeguroDisplay,
                ),
                _buildCheckoutRow('Pacote', _data.pacoteSelecionado),
                if (_data.tipoSeguro == 'Automóvel') ...[
                  _buildCheckoutRow('Veículo',
                      '${_data.marca ?? ''} ${_data.modelo ?? ''}'),
                ],
                _buildCheckoutRow(
                  'Método',
                  _data.metodoPagamento,
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total a Pagar',
                      style:
                          Theme.of(context).textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      '${_data.premioTotal.toStringAsFixed(2)} MZN',
                      style:
                          Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Terms and conditions
          GestureDetector(
            onTap: () {
              setState(() => _data.aceitouTermos = !_data.aceitouTermos);
            },
            child: PremiumGlass(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _data.aceitouTermos
                          ? colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _data.aceitouTermos
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: _data.aceitouTermos
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Li e aceito os Termos e Condições do seguro e a Política de Privacidade da Indico Seguros.',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.4,
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

  // ═══════════════════════════════════════════════════════════════════
  // STEP 6: Success
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStepSuccess() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            Text(
              'Seguro Contratado!',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'O seu seguro foi processado com sucesso.',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Apólice number card
            if (_apoliceNumero != null)
              PremiumGlass(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Nº da Apólice',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _apoliceNumero!,
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                letterSpacing: 1,
                              ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Action buttons
            LiquidGlassButton(
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              label: 'Ir para o Dashboard',
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // TODO: Generate and share PDF certificate
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_outlined,
                      size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Partilhar via WhatsApp',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildGlassInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool hasFile,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: PremiumGlass(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: hasFile
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasFile
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : colorScheme.outline.withValues(alpha: 0.1),
                  style: hasFile ? BorderStyle.solid : BorderStyle.none,
                ),
              ),
              child: Icon(
                hasFile ? Icons.check_circle : icon,
                color: hasFile
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasFile ? 'Documento enviado ✓' : subtitle,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: hasFile
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.camera_alt_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard({
    required String label,
    required IconData icon,
    required bool hasPhoto,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: hasPhoto
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasPhoto
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.1),
            width: hasPhoto ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasPhoto ? Icons.check_circle : Icons.add_a_photo_outlined,
              size: 36,
              color: hasPhoto
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: hasPhoto
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
            if (hasPhoto) ...[
              const SizedBox(height: 4),
              Text(
                'Enviada ✓',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: colorScheme.primary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String name,
    required IconData icon,
    required String description,
    required List<Color> gradientColors,
    bool enabled = true,
  }) {
    final isSelected = _data.metodoPagamento == name;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: enabled
          ? () => setState(() => _data.metodoPagamento = name)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : enabled
                  ? colorScheme.surface
                  : colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Colors.white
                    : enabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : enabled
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? Colors.white
                  : colorScheme.outline.withValues(alpha: 0.2),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
