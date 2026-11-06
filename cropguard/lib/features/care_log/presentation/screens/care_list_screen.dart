import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kroppi/features/care_log/presentation/utils/care_labels.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:kroppi/features/plot_modules/data/plot_modules_remote_data_source.dart';
import 'package:kroppi/navigation/app_routes.dart';

class CareListScreen extends StatefulWidget {
  const CareListScreen({super.key, required this.plotId});

  final String plotId;

  @override
  State<CareListScreen> createState() => _CareListScreenState();
}

class _CareListScreenState extends State<CareListScreen> {
  final _source = PlotModulesRemoteDataSource();
  final _items = <Map<String, dynamic>>[];
  String? _filter;
  String? _error;
  bool _loading = false;
  bool _hasMore = true;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false, int? page}) async {
    if (_loading) return;
    final requestedPage = reset ? 0 : page ?? _pageIndex;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _items.clear();
        _hasMore = true;
      }
    });
    try {
      final pageItems = await _source.getCare(
        widget.plotId,
        type: _filter,
        offset: requestedPage * 50,
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(pageItems);
        _pageIndex = requestedPage;
        _hasMore = pageItems.length == 50;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _message(error);
        _loading = false;
      });
    }
  }

  String _message(Object error) {
    return apiErrorMessage(error);
  }

  Future<void> _openForm() async {
    await context.push(AppRoutes.careNewPath(widget.plotId));
    if (mounted) _load(reset: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cuidados del lote')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _openForm,
      icon: const Icon(Icons.add),
      label: const Text('Registrar cuidado'),
    ),
    body: Column(
      children: [
        SizedBox(
          height: 58,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'Todos',
                selected: _filter == null,
                onTap: () {
                  setState(() => _filter = null);
                  _load(reset: true);
                },
              ),
              for (final entry in careTypes.entries)
                _FilterChip(
                  label: entry.value,
                  selected: _filter == entry.key,
                  onTap: () {
                    setState(() => _filter = entry.key);
                    _load(reset: true);
                  },
                ),
            ],
          ),
        ),
        if (_items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Costo registrado en los resultados cargados: ${NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0).format(_items.fold<double>(0, (total, item) => total + ((item['cost'] as num?)?.toDouble() ?? 0)))}',
              ),
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => _load(reset: true),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: _items.isEmpty && !_loading
                  ? ListView(
                      children: const [
                        SizedBox(height: 130),
                        Icon(Icons.spa_outlined, size: 44),
                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Aún no hay cuidados. Registra el primero.',
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: _items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _items.length) {
                          if (_loading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _pageIndex == 0
                                      ? null
                                      : () => _load(page: _pageIndex - 1),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  label: const Text('Anterior'),
                                ),
                                Text('Página ${_pageIndex + 1}'),
                                OutlinedButton.icon(
                                  onPressed: !_hasMore
                                      ? null
                                      : () => _load(page: _pageIndex + 1),
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('Siguiente'),
                                ),
                              ],
                            ),
                          );
                        }
                        final item = _items[index];
                        final type =
                            item['activity_type'] as String? ?? 'OTHER';
                        final date = DateTime.tryParse(
                          item['applied_at'] as String? ?? '',
                        );
                        return Card(
                          child: ListTile(
                            leading: item['evidence_url'] is String
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.network(
                                      item['evidence_url'] as String,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => CircleAvatar(
                                        child: Icon(_icon(type)),
                                      ),
                                    ),
                                  )
                                : CircleAvatar(child: Icon(_icon(type))),
                            title: Text(
                              item['product_name'] as String? ??
                                  careTypes[type] ??
                                  'Cuidado',
                            ),
                            subtitle: Text(
                              [
                                if (date != null)
                                  DateFormat('d MMM y', 'es').format(date),
                                careTypes[type] ?? type,
                                if (item['quantity'] != null)
                                  '${item['quantity']} ${item['quantity_unit'] ?? ''}',
                              ].join(' · '),
                            ),
                            trailing: item['cost'] == null
                                ? null
                                : Text(
                                    NumberFormat.currency(
                                      locale: 'es_CO',
                                      symbol: r'$',
                                      decimalDigits: 0,
                                    ).format(
                                      num.parse(item['cost'].toString()),
                                    ),
                                  ),
                            onTap: () => context
                                .push(
                                  AppRoutes.careDetailPath(
                                    widget.plotId,
                                    item['id'] as String,
                                  ),
                                )
                                .then((_) => _load(reset: true)),
                          ),
                        );
                      },
                    ),
            ),
          ),
      ],
    ),
  );
}

IconData _icon(String type) => switch (type) {
  'FERTILIZATION' => Icons.grass,
  'FUNGICIDE' || 'INSECTICIDE' || 'HERBICIDE' => Icons.science_outlined,
  'IRRIGATION' => Icons.water_drop_outlined,
  'PRUNING' => Icons.content_cut,
  _ => Icons.eco_outlined,
};

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}
