import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Data class holding all simulation info needed for the PDF.
class CotacaoData {
  final String nomeCliente;
  final String celularCliente;
  final String emailCliente;
  final String tipoSeguro; // 'RC' or 'DP'
  final String tipoVeiculo;
  final String marca;
  final String modelo;
  final String ano;
  final double? valorViatura; // only for DP
  final int? numOcupantes; // only for RC + bus
  final String pacoteSelecionado; // 'Basico', 'Classico', 'Exclusivo'
  final double premioBasico;
  final double premioClassico;
  final double premioExclusivo;

  CotacaoData({
    required this.nomeCliente,
    required this.celularCliente,
    required this.emailCliente,
    required this.tipoSeguro,
    required this.tipoVeiculo,
    required this.marca,
    required this.modelo,
    required this.ano,
    this.valorViatura,
    this.numOcupantes,
    required this.pacoteSelecionado,
    required this.premioBasico,
    required this.premioClassico,
    required this.premioExclusivo,
  });
}

class CotacaoPdfService {
  static const String _logoUrl = 'https://i.imgur.com/6ZyteeN.png';
  static const double _fatorEncargos = 1.1715;

  // Colors matching V1
  static final PdfColor _primaryColor = PdfColor.fromHex("#00AEEF");
  static final PdfColor _greyColor = PdfColor.fromHex("#F0F0F0");
  static final PdfColor _darkGreyColor = PdfColor.fromHex("#B3B3B3");
  static final PdfColor _fontColor = PdfColor.fromHex("#000000");
  static final PdfColor _titleGreyColor = PdfColor.fromHex("#595959");
  static final PdfColor _lightBlueBgColor = PdfColor.fromHex("#EBF8FE");

  /// Generates and shares the PDF cotação.
  static Future<void> gerarPdf(CotacaoData data) async {
    final pdf = pw.Document();

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final response = await http.get(Uri.parse(_logoUrl));
      if (response.statusCode == 200) {
        logoImage = pw.MemoryImage(response.bodyBytes);
      }
    } catch (_) {}

    // Styles
    final boldStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: _fontColor,
      fontSize: 7,
    );
    final normalStyle = pw.TextStyle(
      color: _fontColor,
      fontSize: 7,
      lineSpacing: 1.5,
    );
    final headerStyle = pw.TextStyle(
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
      fontSize: 7,
    );
    final titleGreyBoldStyle = pw.TextStyle(
      color: _titleGreyColor,
      fontWeight: pw.FontWeight.bold,
      fontSize: 9,
    );

    final now = DateTime.now();
    final numeroCotacao = 'VSM-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
    final dataEmissao = DateFormat('dd/MM/yyyy').format(now);
    final dataValidade = DateFormat('dd/MM/yyyy').format(now.add(const Duration(days: 30)));

    final isDP = data.tipoSeguro == 'DP';
    final tipoLabel = isDP ? 'DANOS PRÓPRIOS' : 'RESPONSABILIDADE CIVIL';

    // ================================================================
    // PAGE 1: COTAÇÃO
    // ================================================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (_) => _buildFooter(),
        build: (_) => [
          // Header
          _buildHeader(
            numeroCotacao: numeroCotacao,
            dataEmissao: dataEmissao,
            dataValidade: dataValidade,
            tipoLabel: tipoLabel,
            data: data,
            boldStyle: boldStyle,
            normalStyle: normalStyle,
            logoImage: logoImage,
          ),
          pw.SizedBox(height: 15),
          pw.Text('PRODUTO', style: boldStyle.copyWith(fontSize: 9)),
          pw.SizedBox(height: 4),

          // Coverage table
          isDP
              ? _buildTabelaCoberturasDP(headerStyle, normalStyle, boldStyle)
              : _buildTabelaCoberturasRC(headerStyle, normalStyle, boldStyle),

          // Deductibles (only DP)
          if (isDP) ...[
            pw.SizedBox(height: 2),
            _buildTabelaFranquias(normalStyle, boldStyle),
          ],

          pw.SizedBox(height: 15),
          pw.Text('PRODUTOS E PRÉMIOS TOTAIS', style: boldStyle.copyWith(fontSize: 9)),
          pw.SizedBox(height: 4),
          _buildTabelaPremiosTotais(
            normalStyle: normalStyle,
            boldStyle: boldStyle,
            premioExclusivo: data.premioExclusivo,
            premioClassico: data.premioClassico,
            premioBasico: data.premioBasico,
          ),
        ],
      ),
    );

    // ================================================================
    // PAGE 2: CONDITIONS
    // ================================================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (_) => _buildFooter(),
        build: (_) => [
          pw.Text('CONDIÇÕES PARTICULARES', style: titleGreyBoldStyle),
          pw.SizedBox(height: 5),
          _buildCondicoesParticulares(normalStyle),
          pw.SizedBox(height: 15),
          _buildBlueTitleBar('CONDIÇÕES ESPECIAIS', headerStyle),
          pw.SizedBox(height: 10),
          ..._buildCondicoesEspeciais(normalStyle, boldStyle, isDP: isDP),
        ],
      ),
    );

    // ================================================================
    // PAGE 3: VEHICLE DETAILS
    // ================================================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (_) => _buildFooter(),
        build: (_) => [
          pw.Text('DETALHES DAS VIATURAS E PRÉMIOS',
              style: titleGreyBoldStyle.copyWith(fontSize: 10)),
          pw.SizedBox(height: 15),
          _buildTabelaViatura(
            titulo: 'EXCLUSIVO',
            headerStyle: headerStyle,
            normalStyle: normalStyle,
            boldStyle: boldStyle,
            data: data,
            produto: 'Exclusivo',
            premio: data.premioExclusivo,
            isDP: isDP,
          ),
          pw.SizedBox(height: 15),
          _buildTabelaViatura(
            titulo: 'CLÁSSICO',
            headerStyle: headerStyle,
            normalStyle: normalStyle,
            boldStyle: boldStyle,
            data: data,
            produto: 'Clássico',
            premio: data.premioClassico,
            isDP: isDP,
          ),
          pw.SizedBox(height: 15),
          _buildTabelaViatura(
            titulo: 'BÁSICO',
            headerStyle: headerStyle,
            normalStyle: normalStyle,
            boldStyle: boldStyle,
            data: data,
            produto: 'Básico',
            premio: data.premioBasico,
            isDP: isDP,
          ),
        ],
      ),
    );

    // Share PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'cotacao_$numeroCotacao.pdf',
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────────────────────────────

  static pw.Widget _buildHeader({
    required String numeroCotacao,
    required String dataEmissao,
    required String dataValidade,
    required String tipoLabel,
    required CotacaoData data,
    required pw.TextStyle boldStyle,
    required pw.TextStyle normalStyle,
    pw.MemoryImage? logoImage,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('COTAÇÃO',
                    style: boldStyle.copyWith(fontSize: 16, color: _titleGreyColor)),
                pw.Text('SEGURO AUTOMÓVEL | $tipoLabel',
                    style: boldStyle.copyWith(fontSize: 10, color: _titleGreyColor)),
              ],
            ),
            if (logoImage != null) pw.Image(logoImage, width: 80),
          ],
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _infoRow('NÚMERO DA COTAÇÃO', numeroCotacao, boldStyle, normalStyle),
                    _infoRow('DATA DE EMISSÃO', dataEmissao, boldStyle, normalStyle),
                    _infoRow('VALIDADE', dataValidade, boldStyle, normalStyle),
                    _infoRow('AGÊNCIA', 'Viva Sem Medo', boldStyle, normalStyle),
                    _infoRow('MEDIADOR', '-', boldStyle, normalStyle),
                    _infoRow('SEGMENTO', 'Particular', boldStyle, normalStyle),
                  ],
                ),
              ),
              pw.SizedBox(width: 15),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _infoRow('NOME DO CLIENTE', data.nomeCliente, boldStyle, normalStyle),
                    _infoRow('N. CELULAR', data.celularCliente, boldStyle, normalStyle),
                    _infoRow('E-MAIL', data.emailCliente.isEmpty ? '-' : data.emailCliente, boldStyle, normalStyle),
                    _infoRow('TIPO DE VEÍCULO', data.tipoVeiculo, boldStyle, normalStyle),
                    _infoRow('VIATURA', '${data.marca} ${data.modelo}', boldStyle, normalStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _infoRow(
      String title, String value, pw.TextStyle boldStyle, pw.TextStyle normalStyle) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 100, child: pw.Text(title, style: boldStyle)),
          pw.Expanded(child: pw.Text(value, style: normalStyle)),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // COVERAGE TABLES
  // ──────────────────────────────────────────────────────────────────

  static pw.Widget _buildTabelaCoberturasDP(
      pw.TextStyle headerStyle, pw.TextStyle normalStyle, pw.TextStyle boldStyle) {
    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(2.5),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
      },
      border: pw.TableBorder.all(color: _darkGreyColor, width: 0.5),
      children: [
        _tableHeader(headerStyle),
        _subHeaderRow('COBERTURAS PRINCIPAIS', boldStyle),
        _coverageRow('Choque, colisão e capotamento', 'Coberto: Limite global', 'Coberto: Limite global', 'Coberto: Limite global', normalStyle),
        _coverageRow('Furto ou roubo', 'Coberto: Limite global', 'Coberto: Limite global', 'Não Coberto', normalStyle),
        _coverageRow('Incêndio, raio e/ou explosão', 'Coberto: Limite global', 'Coberto: Limite global', 'Não Coberto', normalStyle),
        _coverageRow('Fenómenos da natureza', 'Coberto: Limite global', 'Não Coberto', 'Não Coberto', normalStyle),
        _coverageRow('Greves e tumultos', 'Coberto: Limite global', 'Coberto: Limite global', 'Não Coberto', normalStyle),
        _subHeaderRow('EXTENSÕES - DP', boldStyle),
        _coverageRow('Furto de peças e acessórios', 'Coberto: 20% limite', 'Coberto: 20% limite', 'Não Coberto', normalStyle),
        _coverageRow('Quebra isolada de vidros', 'Coberto: 20% limite', 'Coberto: 20% limite', 'Coberto: 20% limite', normalStyle),
        _coverageRow('Perda de chaves', 'MZN 45,000.00', 'MZN 35,000.00', 'Não Coberto', normalStyle),
        _coverageRow('Reboque', 'MZN 45,000.00', 'MZN 45,000.00', 'Não Coberto', normalStyle),
        _subHeaderRow('RESPONSABILIDADE CIVIL', boldStyle),
        _coverageRow('Limite Global', 'MZN 8,000,000.00', 'MZN 5,400,000.00', 'MZN 3,000,000.00', normalStyle),
        _subHeaderRow('OCUPANTE', boldStyle),
        _coverageRow('Morte/Invalidez', 'MZN 200,000.00', 'MZN 100,000.00', 'MZN 50,000.00', normalStyle),
        _coverageRow('Despesas médicas', 'MZN 30,000.00', 'MZN 20,000.00', 'MZN 10,000.00', normalStyle),
        _coverageRow('Despesas de funeral', 'MZN 15,000.00', 'MZN 10,000.00', 'MZN 5,000.00', normalStyle),
      ],
    );
  }

  static pw.Widget _buildTabelaCoberturasRC(
      pw.TextStyle headerStyle, pw.TextStyle normalStyle, pw.TextStyle boldStyle) {
    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(2.5),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
      },
      border: pw.TableBorder.all(color: _darkGreyColor, width: 0.5),
      children: [
        _tableHeader(headerStyle),
        _subHeaderRow('COBERTURAS PRINCIPAIS', boldStyle),
        _coverageRow('Responsabilidade de Terceiros', 'MZN 5,400,000.00', 'MZN 3,000,000.00', 'MZN 2,800,000.00', normalStyle),
        _subHeaderRow('EXTENSÕES - OCUPANTE', boldStyle),
        _coverageRow('Morte/Invalidez permanente', 'MZN 25,000.00', 'MZN 25,000.00', 'Não Coberto', normalStyle),
        _coverageRow('Despesas médicas', 'MZN 10,000.00', 'MZN 5,000.00', 'Não Coberto', normalStyle),
        _coverageRow('Despesas de funeral', 'MZN 5,000.00', 'MZN 2,500.00', 'Não Coberto', normalStyle),
        _subHeaderRow('BENEFÍCIOS FUNERÁRIOS', boldStyle),
        _coverageRow('Tomador e agregado até 5 membros', 'MZN 25,000.00', 'MZN 25,000.00', 'Não Coberto', normalStyle),
      ],
    );
  }

  static pw.TableRow _tableHeader(pw.TextStyle headerStyle) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: _primaryColor),
      children: [
        pw.Container(padding: const pw.EdgeInsets.all(3), child: pw.Text('COBERTURAS', style: headerStyle.copyWith(fontSize: 9))),
        pw.Container(padding: const pw.EdgeInsets.all(3), alignment: pw.Alignment.center, child: pw.Text('EXCLUSIVO', style: headerStyle)),
        pw.Container(padding: const pw.EdgeInsets.all(3), alignment: pw.Alignment.center, child: pw.Text('CLÁSSICO', style: headerStyle)),
        pw.Container(padding: const pw.EdgeInsets.all(3), alignment: pw.Alignment.center, child: pw.Text('BÁSICO', style: headerStyle)),
      ],
    );
  }

  static pw.TableRow _subHeaderRow(String title, pw.TextStyle boldStyle) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: _greyColor),
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(title, style: boldStyle)),
        pw.Container(), pw.Container(), pw.Container(),
      ],
    );
  }

  static pw.TableRow _coverageRow(
      String label, String excl, String clas, String bas, pw.TextStyle style) {
    return pw.TableRow(children: [
      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(label, style: style)),
      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(excl, style: style, textAlign: pw.TextAlign.center)),
      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(clas, style: style, textAlign: pw.TextAlign.center)),
      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(bas, style: style, textAlign: pw.TextAlign.center)),
    ]);
  }

  // ──────────────────────────────────────────────────────────────────
  // DEDUCTIBLES (DP only)
  // ──────────────────────────────────────────────────────────────────

  static pw.Widget _buildTabelaFranquias(pw.TextStyle normalStyle, pw.TextStyle boldStyle) {
    const franquiaClas =
        'Geral: 10% do sinistro, mín. MZN 10,800.00\n'
        'Furto ou Roubo: 20% do valor da viatura\n'
        'Vidros e acessórios: 10% do sinistro, mín. MZN 2,800.00\n'
        'Perda de chaves: MZN 5,000.00';
    const franquiaBas =
        'Geral: 10% do sinistro, mín. MZN 12,400.00\n'
        'Furto ou Roubo: 20% do valor da viatura\n'
        'Vidros e acessórios: 10% do sinistro, mín. MZN 2,800.00';

    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(2.5),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
      },
      border: pw.TableBorder.all(color: _darkGreyColor, width: 0.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _greyColor),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('FRANQUIAS', style: boldStyle)),
            pw.Container(), pw.Container(), pw.Container(),
          ],
        ),
        pw.TableRow(children: [
          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Ligeiros', style: normalStyle)),
          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('SEM FRANQUIA', style: normalStyle, textAlign: pw.TextAlign.center)),
          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(franquiaClas, style: normalStyle.copyWith(fontSize: 6))),
          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(franquiaBas, style: normalStyle.copyWith(fontSize: 6))),
        ]),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // PREMIUMS TABLE
  // ──────────────────────────────────────────────────────────────────

  static pw.Widget _buildTabelaPremiosTotais({
    required pw.TextStyle normalStyle,
    required pw.TextStyle boldStyle,
    required double premioExclusivo,
    required double premioClassico,
    required double premioBasico,
  }) {
    final header = pw.TableRow(
      decoration: pw.BoxDecoration(color: _primaryColor),
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('PRODUTO', style: boldStyle.copyWith(color: PdfColors.white))),
        pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('PRÉMIO SIMPLES', style: boldStyle.copyWith(color: PdfColors.white))),
        pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('ENCARGOS', style: boldStyle.copyWith(color: PdfColors.white))),
        pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('PRÉMIO BRUTO/ANO', style: boldStyle.copyWith(color: PdfColors.white))),
      ],
    );

    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(0.8),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.2),
      },
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        header,
        _premiumRow('EXCLUSIVO', premioExclusivo, boldStyle, normalStyle),
        _premiumRow('CLÁSSICO', premioClassico, boldStyle, normalStyle),
        _premiumRow('BÁSICO', premioBasico, boldStyle, normalStyle),
      ],
    );
  }

  static pw.TableRow _premiumRow(
      String produto, double premioBruto, pw.TextStyle boldStyle, pw.TextStyle normalStyle) {
    final premioSimples = premioBruto / _fatorEncargos;
    final despAdmin = premioSimples * 0.10;
    final sobreTaxa = premioSimples * 0.0165;
    final impostoSelo = premioSimples * 0.055;

    pw.Widget encargoLine(String label, double value) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: normalStyle),
          pw.Text(value.toStringAsFixed(2), style: normalStyle),
        ],
      );
    }

    return pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(produto, style: boldStyle)),
        pw.Padding(
          padding: const pw.EdgeInsets.all(3),
          child: pw.Text(_currency(premioSimples), style: normalStyle, textAlign: pw.TextAlign.center),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              encargoLine('Despesas Admin.', despAdmin),
              encargoLine('Sobre Taxa', sobreTaxa),
              encargoLine('Imposto Selo', impostoSelo),
            ],
          ),
        ),
        pw.Container(
          color: _lightBlueBgColor,
          height: 40,
          alignment: pw.Alignment.center,
          child: pw.Text(_currency(premioBruto), style: boldStyle),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // CONDITIONS
  // ──────────────────────────────────────────────────────────────────

  static pw.Widget _buildCondicoesParticulares(pw.TextStyle normalStyle) {
    return pw.Container(
      decoration: pw.BoxDecoration(color: _greyColor, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2))),
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('1. A viatura se encontra em bom estado de conservação.', style: normalStyle),
          pw.SizedBox(height: 4),
          pw.Text('2. Utilização da viatura: Particular.', style: normalStyle),
          pw.SizedBox(height: 4),
          pw.Text('3. Outras características particulares: N/A', style: normalStyle),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildCondicoesEspeciais(
      pw.TextStyle normalStyle, pw.TextStyle boldStyle, {required bool isDP}) {
    final widgets = <pw.Widget>[
      pw.Text('Garantias de Cobertura', style: boldStyle.copyWith(fontSize: 9)),
      pw.Container(
        decoration: pw.BoxDecoration(color: _greyColor, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2))),
        padding: const pw.EdgeInsets.all(6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('As viaturas devem permanecer em bom estado de conservação durante a vigência do seguro.', style: normalStyle),
            pw.SizedBox(height: 3),
            pw.Text('Deve-se garantir a inspeção regular conforme exigível por lei.', style: normalStyle),
            pw.SizedBox(height: 3),
            pw.Text('O prémio anual deve ser pago até a data prevista na apólice.', style: normalStyle),
          ],
        ),
      ),
    ];

    if (isDP) {
      widgets.addAll([
        pw.SizedBox(height: 10),
        pw.Text('Base de Indemnização', style: boldStyle.copyWith(fontSize: 9)),
        pw.Container(
          decoration: pw.BoxDecoration(color: _greyColor, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2))),
          padding: const pw.EdgeInsets.all(6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('A indemnização será calculada na base do valor de mercado (valor venal no momento do sinistro).', style: normalStyle),
              pw.SizedBox(height: 3),
              pw.Text('O capital declarado deve corresponder ao valor de mercado ou valor de reposição em novo.', style: normalStyle),
            ],
          ),
        ),
      ]);
    }

    widgets.addAll([
      pw.SizedBox(height: 10),
      pw.Text('Validade da Cotação', style: boldStyle.copyWith(fontSize: 9)),
      pw.Container(
        decoration: pw.BoxDecoration(color: _greyColor, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2))),
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          'A presente cotação é válida por 30 dias. Vencido o prazo, deve ser solicitada nova cotação.',
          style: normalStyle,
        ),
      ),
    ]);

    return widgets;
  }

  // ──────────────────────────────────────────────────────────────────
  // VEHICLE DETAILS TABLE
  // ──────────────────────────────────────────────────────────────────

  static pw.Widget _buildTabelaViatura({
    required String titulo,
    required pw.TextStyle headerStyle,
    required pw.TextStyle normalStyle,
    required pw.TextStyle boldStyle,
    required CotacaoData data,
    required String produto,
    required double premio,
    required bool isDP,
  }) {
    final columns = isDP
        ? const {
            0: pw.FlexColumnWidth(0.4),
            1: pw.FlexColumnWidth(1.2),
            2: pw.FlexColumnWidth(1.2),
            3: pw.FlexColumnWidth(0.7),
            4: pw.FlexColumnWidth(1.3),
            5: pw.FlexColumnWidth(1.0),
            6: pw.FlexColumnWidth(1.2),
          }
        : const {
            0: pw.FlexColumnWidth(0.4),
            1: pw.FlexColumnWidth(1.3),
            2: pw.FlexColumnWidth(1.3),
            3: pw.FlexColumnWidth(0.8),
            4: pw.FlexColumnWidth(1.2),
            5: pw.FlexColumnWidth(1.2),
          };

    final headerCells = isDP
        ? ['NO', 'MARCA', 'MODELO', 'ANO', 'VALOR VIATURA', 'PRODUTO', 'PRÉMIO']
        : ['NO', 'MARCA', 'MODELO', 'ANO', 'PRODUTO', 'PRÉMIO'];

    final dataCells = isDP
        ? ['1', data.marca, data.modelo, data.ano, _currency(data.valorViatura ?? 0), produto, _currency(premio)]
        : ['1', data.marca, data.modelo, data.ano, produto, _currency(premio)];

    final totalCells = List.generate(
      headerCells.length,
      (i) {
        if (i == headerCells.length - 2) return 'TOTAL';
        if (i == headerCells.length - 1) return _currency(premio);
        return '';
      },
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildBlueTitleBar(titulo, headerStyle),
        pw.Table(
          columnWidths: columns,
          border: pw.TableBorder.all(color: PdfColors.grey),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: headerCells.map((h) => pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(h, style: boldStyle))).toList(),
            ),
            pw.TableRow(
              children: dataCells.map((d) => pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(d, style: normalStyle))).toList(),
            ),
            pw.TableRow(
              children: totalCells.map((t) {
                if (t == 'TOTAL') return pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(t, style: boldStyle));
                if (t.startsWith('MZN')) return pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(t, style: boldStyle));
                return pw.Container();
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // SHARED HELPERS
  // ──────────────────────────────────────────────────────────────────

  static pw.Widget _buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('F.DP.32 R0', style: const pw.TextStyle(fontSize: 7)),
        pw.Text(
          'LINHAS DE ATENDIMENTO Cell: 82/84 5533 Whatsapp: 85 272 7270 Email: linhadocliente@indicoseguros.co.mz',
          style: const pw.TextStyle(fontSize: 7),
        ),
      ],
    );
  }

  static pw.Widget _buildBlueTitleBar(String title, pw.TextStyle headerStyle) {
    return pw.Container(
      width: double.infinity,
      color: _primaryColor,
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(title, style: headerStyle.copyWith(fontSize: 9)),
    );
  }

  static String _currency(double value) {
    return 'MZN ${value.toStringAsFixed(2)}';
  }
}
