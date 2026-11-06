import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:kroppi/features/plot_modules/data/plot_modules_remote_data_source.dart';
import 'package:kroppi/navigation/app_routes.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({
    super.key,
    required this.plotId,
    this.initialReportId,
  });

  final String plotId;
  final String? initialReportId;

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final _source = PlotModulesRemoteDataSource();
  List<Map<String, dynamic>> _reports = [];
  String? _error;
  bool _loading = true;
  bool _openedInitialReport = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _source.getReports(widget.plotId);
      if (mounted) {
        setState(() {
          _reports = result;
          _loading = false;
        });
        final initialId = widget.initialReportId;
        if (!_openedInitialReport && initialId != null) {
          _openedInitialReport = true;
          final report = result.where((item) => item['id'] == initialId);
          if (report.isNotEmpty) _open(report.first);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = apiErrorMessage(error);
          _loading = false;
        });
      }
    }
  }

  Future<void> _open(Map<String, dynamic> report) async {
    try {
      final result = await _source.getReport(report['id'] as String);
      final url = result['file_url'] as String?;
      if (url == null) {
        throw StateError('El informe no tiene un archivo asociado.');
      }
      final response = await PlotModulesRemoteDataSource().downloadFile(url);
      await Printing.layoutPdf(onLayout: (_) async => response);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _share(Map<String, dynamic> report) async {
    try {
      final result = await _source.getReport(report['id'] as String);
      final url = result['file_url'] as String?;
      if (url == null) {
        throw StateError('El informe no tiene un archivo asociado.');
      }
      final bytes = await _source.downloadFile(url);
      final filename = 'Informe_${report['id']}.pdf';
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes, mimeType: 'application/pdf', name: filename),
          ],
          fileNameOverrides: [filename],
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar informe'),
        content: const Text('¿Quieres eliminar este informe y su archivo PDF?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _source.deleteReport(id);
      _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Informes del lote')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context
          .push(AppRoutes.reportNewPath(widget.plotId))
          .then((_) => _load()),
      icon: const Icon(Icons.picture_as_pdf_outlined),
      label: const Text('Generar informe'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                TextButton(onPressed: _load, child: const Text('Reintentar')),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: _reports.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 130),
                      Icon(Icons.description_outlined, size: 44),
                      SizedBox(height: 12),
                      Center(child: Text('Aún no hay informes de este lote.')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      final summary =
                          report['summary'] as Map<String, dynamic>? ?? {};
                      final generated = DateTime.tryParse(
                        report['created_at'] as String? ?? '',
                      );
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf_outlined),
                          title: Text(
                            'Informe · ${report['period_from']} a ${report['period_to']}',
                          ),
                          subtitle: Text(
                            [
                              if (generated != null)
                                DateFormat(
                                  'd MMM y',
                                  'es',
                                ).format(generated.toLocal()),
                              if (report['file_size_bytes'] != null)
                                '${((report['file_size_bytes'] as num) / 1024).round()} KB',
                              if (summary['harvested_kg'] != null)
                                '${summary['harvested_kg']} kg cosechados',
                            ].join(' · '),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'open') _open(report);
                              if (value == 'share') _share(report);
                              if (value == 'delete') {
                                _delete(report['id'] as String);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'open',
                                child: Text('Ver PDF'),
                              ),
                              PopupMenuItem(
                                value: 'share',
                                child: Text('Compartir'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                          onTap: () => _open(report),
                        ),
                      );
                    },
                  ),
          ),
  );
}
