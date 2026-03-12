import 'package:flutter/material.dart';
import 'simulacao_result_page.dart';

class SimulacaoFormPage extends StatefulWidget {
  const SimulacaoFormPage({super.key});

  @override
  State<SimulacaoFormPage> createState() => _SimulacaoFormPageState();
}

class _SimulacaoFormPageState extends State<SimulacaoFormPage> {
  final _formKey = GlobalKey<FormState>();

  String? _tipoSeguro; // 'RC' ou 'DP'
  String? _tipoVeiculo;
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _matriculaController = TextEditingController();
  final _valorController = TextEditingController();
  final _numOcupantesController = TextEditingController(text: '1');
  final _numVeiculosController = TextEditingController(text: '1');

  final List<String> _tiposVeiculoRC = [
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

  final List<String> _tiposVeiculoDP = [
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
    _marcaController.dispose();
    _modeloController.dispose();
    _matriculaController.dispose();
    _valorController.dispose();
    _numOcupantesController.dispose();
    _numVeiculosController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_tipoSeguro == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione o tipo de seguro')),
        );
        return;
      }
      
      if (_tipoVeiculo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione o tipo de veículo')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SimulacaoResultPage(
            tipoSeguro: _tipoSeguro!,
            tipoVeiculo: _tipoVeiculo!,
            marca: _marcaController.text.trim(),
            modelo: _modeloController.text.trim(),
            matricula: _matriculaController.text.trim(),
            valorEstimado: double.tryParse(_valorController.text.trim()) ?? 0.0,
            numOcupantes: int.tryParse(_numOcupantesController.text.trim()) ?? 1,
            numVeiculos: int.tryParse(_numVeiculosController.text.trim()) ?? 1,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRC = _tipoSeguro == 'RC';
    final isDP = _tipoSeguro == 'DP';
    final tiposVeiculo = isRC ? _tiposVeiculoRC : (isDP ? _tiposVeiculoDP : <String>[]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Simulação Automóvel',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF4F4),
              Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Preencha os dados da viatura',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    DropdownButtonFormField<String>(
                      initialValue: _tipoSeguro,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Seguro',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'RC',
                          child: Text('Responsabilidade Civil'),
                        ),
                        DropdownMenuItem(
                          value: 'DP',
                          child: Text('Danos Próprios'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _tipoSeguro = value;
                          _tipoVeiculo = null; // Reset vehicle type on switch
                        });
                      },
                      validator: (value) => value == null ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    if (_tipoSeguro != null) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _tipoVeiculo,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Veículo',
                          border: OutlineInputBorder(),
                        ),
                        items: tiposVeiculo.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _tipoVeiculo = value;
                          });
                        },
                        validator: (value) => value == null ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _marcaController,
                        decoration: const InputDecoration(
                          labelText: 'Marca (Ex: Toyota)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _modeloController,
                        decoration: const InputDecoration(
                          labelText: 'Modelo (Ex: Corolla)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _matriculaController,
                        decoration: const InputDecoration(
                          labelText: 'Matrícula (Ex: AAA 111 MC)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),

                      if (!isRC) ...[
                        TextFormField(
                          controller: _valorController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Valor Estimado (MZN)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return 'Obrigatório para DP';
                            if (double.tryParse(value) == null) return 'Valor inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _numVeiculosController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Nº Viaturas',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          if (isRC) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _numOcupantesController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Nº Ocupantes',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Simular Prêmio', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

