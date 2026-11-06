import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:kroppi/features/plot_modules/data/plot_modules_remote_data_source.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

const _disclaimer =
    'Resultados orientativos generados con apoyo de inteligencia artificial. Confirme con un agrónomo o técnico de campo.';

class ReportSetupScreen extends StatefulWidget {
  const ReportSetupScreen({super.key, required this.plotId});

  final String plotId;

  @override
  State<ReportSetupScreen> createState() => _ReportSetupScreenState();
}

class _ReportSetupScreenState extends State<ReportSetupScreen> {
  final _source = PlotModulesRemoteDataSource();
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  bool _includePhotos = true;
  bool _includeEvidence = true;
  bool _includeCharts = true;
  bool _working = false;
  Uint8List? _pdfBytes;
  String? _filename;
  String? _error;

  Future<void> _pickRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (result != null && mounted) {
      setState(() {
        _from = result.start;
        _to = result.end;
      });
    }
  }

  Future<void> _generate() async {
    if (_from.isAfter(_to)) {
      setState(
        () => _error = 'La fecha inicial debe ser anterior a la fecha final.',
      );
      return;
    }
    setState(() {
      _working = true;
      _error = null;
      _pdfBytes = null;
    });
    try {
      final data = await _source.getReportData(
        widget.plotId,
        from: _from,
        to: _to,
      );
      final (sampleImages, evidenceImages) = await _loadImages(data);
      final bytes = await _buildPdf(data, sampleImages, evidenceImages);
      final plot =
          (data['identification'] as Map<String, dynamic>)['plot']
              as Map<String, dynamic>;
      final safeName = (plot['name'] as String? ?? 'Lote').replaceAll(
        RegExp(r'[^A-Za-z0-9_-]'),
        '_',
      );
      final filename =
          'Informe_${safeName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      setState(() {
        _pdfBytes = bytes;
        _filename = filename;
      });
      try {
        await _source.uploadReport(
          plotId: widget.plotId,
          from: _from,
          to: _to,
          bytes: bytes,
          filename: filename,
        );
      } catch (error) {
        if (mounted) {
          setState(
            () => _error =
                'No se pudo guardar el informe en tu cuenta. Puedes verlo o compartirlo y reintentar después. $error',
          );
        }
      }
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  String _message(Object error) {
    return apiErrorMessage(error);
  }

  Future<(List<pw.MemoryImage>, List<pw.MemoryImage>)> _loadImages(
    Map<String, dynamic> data,
  ) async {
    final sampleUrls = <String>[];
    final evidenceUrls = <String>[];
    if (_includePhotos) {
      for (final item in (data['sample_photos'] as List? ?? const [])) {
        if (item['signed_url'] is String) {
          sampleUrls.add(item['signed_url'] as String);
        }
      }
    }
    if (_includeEvidence) {
      for (final item in (data['care_activities'] as List? ?? const [])) {
        if (item['evidence_url'] is String) {
          evidenceUrls.add(item['evidence_url'] as String);
        }
      }
    }
    Future<List<pw.MemoryImage>> load(List<String> urls) async {
      final images = <pw.MemoryImage>[];
      for (final url in urls) {
        try {
          final response = await Dio().get<List<int>>(
            url,
            options: Options(responseType: ResponseType.bytes),
          );
          if (response.data != null) {
            images.add(pw.MemoryImage(Uint8List.fromList(response.data!)));
          }
        } on DioException {
          // A signed image can expire; omit it without stopping report creation.
        }
      }
      return images;
    }

    return (await load(sampleUrls), await load(evidenceUrls));
  }

  Future<Uint8List> _buildPdf(
    Map<String, dynamic> data,
    List<pw.MemoryImage> sampleImages,
    List<pw.MemoryImage> evidenceImages,
  ) async {
    final document = pw.Document();
    final identification = data['identification'] as Map<String, dynamic>;
    final farm = identification['farm'] as Map<String, dynamic>;
    final crop = identification['crop'] as Map<String, dynamic>;
    final plot = identification['plot'] as Map<String, dynamic>;
    final samples = (data['samples'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final diseases = (data['disease_breakdown'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final care = (data['care_activities'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final harvests = (data['harvests'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final production = data['production'] as Map<String, dynamic>? ?? {};
    final losses = data['losses'] as Map<String, dynamic>?;
    final conclusions = data['conclusions'] as Map<String, dynamic>? ?? {};
    final charts = data['chart_series'] as Map<String, dynamic>? ?? {};
    final period = data['period'] as Map<String, dynamic>;

    pw.Widget section(String title, List<pw.Widget> contents) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(),
        ...contents,
      ],
    );

    pw.Widget table(List<String> headers, List<List<String>> rows) =>
        rows.isEmpty
        ? pw.Text('Sin registros en el periodo')
        : pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
          );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                _disclaimer,
                style: const pw.TextStyle(fontSize: 7),
              ),
            ),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        build: (context) => [
          pw.Text(
            'Kroppi',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Informe de auditoría del lote',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Generado: ${data['generated_at']}'),
          pw.Text('Periodo: ${period['from']} a ${period['to']}'),
          section('Identificación', [
            pw.Text(
              'Finca: ${farm['name']} · ${farm['municipality'] ?? ''}, ${farm['department'] ?? ''}',
            ),
            pw.Text('Cultivo: ${crop['name']} (${crop['type']})'),
            pw.Text(
              'Lote: ${plot['name']} · ${plot['area_ha']} ha · Estado: ${plot['status']}',
            ),
          ]),
          section('Muestreos', [
            table(
              [
                'Fecha',
                'Método',
                'Evaluadas',
                'Afectadas',
                'Incidencia',
                'Estado',
              ],
              samples
                  .map(
                    (row) => [
                      row['sampled_at'].toString().split('T').first,
                      row['method']?.toString() ?? '',
                      row['plants_evaluated'].toString(),
                      row['plants_affected'].toString(),
                      '${row['incidence_pct']} %',
                      row['status']?.toString() ?? '',
                    ],
                  )
                  .toList(),
            ),
            if (_includeCharts)
              pw.Text(
                'Incidencia por muestreo: ${(charts['incidence'] as List? ?? []).map((r) => '${r['incidence_pct']}%').join(' · ')}',
              ),
          ]),
          section('Diagnósticos encontrados', [
            table(
              ['Enfermedad', 'Casos', 'Porcentaje'],
              diseases
                  .map(
                    (row) => [
                      row['disease_name'].toString(),
                      row['count'].toString(),
                      '${row['pct']} %',
                    ],
                  )
                  .toList(),
            ),
            if (_includePhotos && sampleImages.isNotEmpty)
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sampleImages
                    .take(6)
                    .map(
                      (image) => pw.Container(
                        width: 140,
                        height: 100,
                        child: pw.Image(image, fit: pw.BoxFit.cover),
                      ),
                    )
                    .toList(),
              ),
          ]),
          section('Evolución de enfermedades', [
            table(
              ['Periodo', 'Código', 'Detecciones'],
              ((data['disease_evolution'] as List? ?? const [])
                      .cast<Map<String, dynamic>>())
                  .map(
                    (row) => [
                      row['period'].toString(),
                      row['disease_code'].toString(),
                      row['count'].toString(),
                    ],
                  )
                  .toList(),
            ),
          ]),
          section('Cuidados registrados', [
            table(
              [
                'Fecha',
                'Actividad',
                'Producto',
                'Ingrediente',
                'Cantidad',
                'Costo COP',
              ],
              care
                  .map(
                    (row) => [
                      row['applied_at'].toString(),
                      row['activity_type'].toString(),
                      row['product_name']?.toString() ?? '',
                      row['active_ingredient']?.toString() ?? '',
                      '${row['quantity'] ?? ''} ${row['quantity_unit'] ?? ''}',
                      row['cost']?.toString() ?? '',
                    ],
                  )
                  .toList(),
            ),
            pw.Text(
              'Costo total de cuidados: ${data['costs']?['care_cost_cop'] ?? 0} COP',
            ),
            if (_includeEvidence && evidenceImages.isNotEmpty)
              pw.Wrap(
                spacing: 8,
                children: evidenceImages
                    .take(10)
                    .map(
                      (image) => pw.Container(
                        width: 100,
                        height: 75,
                        child: pw.Image(image, fit: pw.BoxFit.cover),
                      ),
                    )
                    .toList(),
              ),
          ]),
          section('Producción y cosechas', [
            table(
              ['Fecha', 'Kg', 'Precio/kg', 'Valor COP'],
              harvests
                  .map(
                    (row) => [
                      row['harvested_at'].toString(),
                      row['quantity_kg'].toString(),
                      row['price_per_kg']?.toString() ?? 'Sin precio',
                      row['value_cop']?.toString() ?? '',
                    ],
                  )
                  .toList(),
            ),
            pw.Text(
              'Total: ${production['harvested_kg'] ?? 0} kg · Ingresos: ${production['revenue_cop'] ?? 0} COP',
            ),
          ]),
          section('Pérdidas económicas', [
            if (losses == null)
              pw.Text('No hay estimación de pérdidas en el periodo')
            else
              pw.Text(
                'Esperados: ${losses['expected_kg'] ?? 'Sin dato'} kg · Cosechados: ${losses['harvested_kg'] ?? 0} kg · '
                'Perdidos: ${losses['lost_kg'] ?? 'Sin dato'} kg · Porcentaje: ${losses['loss_pct'] ?? 'Sin dato'} % · '
                'Monto: ${losses['loss_amount_cop'] ?? 'Sin dato'} COP',
              ),
          ]),
          section('Conclusiones del periodo', [
            pw.Text(
              conclusions['summary_text']?.toString() ??
                  'Sin registros en el periodo',
            ),
            for (final bullet in (conclusions['bullets'] as List? ?? const []))
              pw.Bullet(text: bullet.toString()),
          ]),
          pw.SizedBox(height: 12),
          pw.Text(_disclaimer, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
    return document.save();
  }

  Future<void> _print() async {
    final bytes = _pdfBytes;
    if (bytes != null) await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _share() async {
    final bytes = _pdfBytes;
    final filename = _filename;
    if (bytes == null || filename == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'application/pdf', name: filename),
        ],
        fileNameOverrides: [filename],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Generar informe PDF')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Informe por lote', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text(
          'El PDF se genera en el dispositivo y se registra para consultarlo después.',
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Periodo'),
            subtitle: Text(
              '${DateFormat('d MMM y', 'es').format(_from)} – ${DateFormat('d MMM y', 'es').format(_to)}',
            ),
            onTap: _pickRange,
          ),
        ),
        for (final entry in [
          (
            'Incluir fotos de ejemplo',
            _includePhotos,
            (bool value) => _includePhotos = value,
          ),
          (
            'Incluir evidencias de cuidados',
            _includeEvidence,
            (bool value) => _includeEvidence = value,
          ),
          (
            'Incluir series de gráficas',
            _includeCharts,
            (bool value) => _includeCharts = value,
          ),
        ])
          SwitchListTile(
            title: Text(entry.$1),
            value: entry.$2,
            onChanged: (value) => setState(() => entry.$3(value)),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        FilledButton.icon(
          onPressed: _working ? null : _generate,
          icon: _working
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf),
          label: Text(
            _working ? 'Reuniendo datos y armando PDF…' : 'Generar informe',
          ),
        ),
        if (_pdfBytes != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _print,
                  icon: const Icon(Icons.print),
                  label: const Text('Ver / imprimir'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                ),
              ),
            ],
          ),
          if (_error != null)
            TextButton(
              onPressed: _working ? null : _generate,
              child: const Text('Reintentar guardado del informe'),
            ),
          PdfPreview(
            build: (_) async => _pdfBytes!,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Volver a los informes'),
          ),
        ],
      ],
    ),
  );
}
