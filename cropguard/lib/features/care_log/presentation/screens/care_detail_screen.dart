import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:kroppi/features/care_log/presentation/utils/care_labels.dart';
import 'package:kroppi/features/plot_modules/data/plot_modules_remote_data_source.dart';
import 'package:kroppi/navigation/app_routes.dart';

class CareDetailScreen extends StatefulWidget {
  const CareDetailScreen({super.key, required this.plotId, required this.activityId});

  final String plotId;
  final String activityId;

  @override
  State<CareDetailScreen> createState() => _CareDetailScreenState();
}

class _CareDetailScreenState extends State<CareDetailScreen> {
  final _source = PlotModulesRemoteDataSource();
  Map<String, dynamic>? _item;
  String? _error;
  bool _loading = true;

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
      final item = await _source.getCareById(widget.activityId);
      if (context.mounted) {
        setState(() {
          _item = item;
          _loading = false;
        });
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

  Future<void> _edit() async {
    final changed = await context.push<bool>(
      AppRoutes.careEditPath(widget.plotId, widget.activityId),
      extra: _item,
    );
    if (changed == true && mounted) _load();
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuidado'),
        content: const Text('¿Eliminar este cuidado? Se borrará también la foto.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _source.deleteCare(widget.activityId);
      if (mounted) context.pop(true);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del cuidado'),
        actions: [
          if (item != null) IconButton(onPressed: _edit, icon: const Icon(Icons.edit_outlined)),
          if (item != null) IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : item == null
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error ?? 'No se encontró el cuidado.'),
                    TextButton(onPressed: _load, child: const Text('Reintentar')),
                  ],
                ))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      item['product_name'] as String? ??
                          careTypes[item['activity_type']] ?? 'Cuidado',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    _detail('Fecha', DateFormat('d MMM y', 'es').format(
                      DateTime.parse(item['applied_at'] as String),
                    )),
                    _detail('Tipo', careTypes[item['activity_type']] ?? item['activity_type'].toString()),
                    _detail('Ingrediente activo', item['active_ingredient']),
                    _detail('Cantidad', item['quantity'] == null ? null :
                      '${item['quantity']} ${item['quantity_unit'] ?? ''}'),
                    _detail('Método', careMethods[item['application_method']] ?? item['application_method']),
                    _detail('Enfermedad objetivo', item['target_disease_code']),
                    _detail('Costo', item['cost'] == null ? null : NumberFormat.currency(
                      locale: 'es_CO', symbol: r'$', decimalDigits: 0,
                    ).format(num.parse(item['cost'].toString()))),
                    _detail('Observaciones', item['notes']),
                    if (item['evidence_url'] is String)
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.network(
                              item['evidence_url'] as String,
                              errorBuilder: (_, _, _) => const Text(
                                'No se pudo cargar la evidencia. Recarga para obtener una URL nueva.',
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                try {
                                  await _source.deleteCareEvidence(widget.activityId);
                                  await _load();
                                } catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Quitar evidencia'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _detail(String label, Object? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 145, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(child: Text(value?.toString() ?? 'Sin registro')),
      ],
    ),
  );
}
