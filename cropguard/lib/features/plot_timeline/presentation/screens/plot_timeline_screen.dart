import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:kroppi/features/plot_modules/data/plot_modules_remote_data_source.dart';
import 'package:kroppi/navigation/app_routes.dart';

const _eventTypes = <String, String>{
  'sample': 'Muestreos',
  'diagnosis': 'Diagnósticos',
  'care': 'Cuidados',
  'harvest': 'Cosechas',
  'loss': 'Pérdidas',
  'report': 'Informes',
};

class PlotTimelineScreen extends StatefulWidget {
  const PlotTimelineScreen({super.key, required this.plotId});

  final String plotId;

  @override
  State<PlotTimelineScreen> createState() => _PlotTimelineScreenState();
}

class _PlotTimelineScreenState extends State<PlotTimelineScreen> {
  final _source = PlotModulesRemoteDataSource();
  final _scroll = ScrollController();
  final _items = <Map<String, dynamic>>[];
  final _selectedTypes = _eventTypes.keys.toSet();
  String? _before;
  String? _error;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 350 && _hasMore && !_loading) _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    if (reset) {
      _items.clear();
      _before = null;
      _hasMore = true;
    }
    if (_selectedTypes.isEmpty) {
      setState(() {
        _loading = false;
        _error = null;
        _hasMore = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _source.getTimeline(
        widget.plotId,
        before: _before,
        types: _selectedTypes.toList(),
      );
      if (!mounted) return;
      final page = (response['items'] as List).cast<Map<String, dynamic>>();
      setState(() {
        _items.addAll(page.where((item) => !_items.any((old) => old['id'] == item['id'])));
        _before = response['next_before'] as String?;
        _hasMore = _before != null;
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

  void _toggle(String type, bool selected) {
    setState(() {
      if (selected) {
        _selectedTypes.add(type);
      } else {
        _selectedTypes.remove(type);
      }
    });
    _load(reset: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Historial del lote')),
    body: Column(
      children: [
        SizedBox(
          height: 58,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            scrollDirection: Axis.horizontal,
            children: [
              for (final entry in _eventTypes.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: _selectedTypes.contains(entry.key),
                    onSelected: (value) => _toggle(entry.key, value),
                  ),
                ),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                TextButton(onPressed: () => _load(reset: true), child: const Text('Reintentar')),
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
                        Icon(Icons.history, size: 44),
                        SizedBox(height: 12),
                        Center(child: Text('Aún no hay actividad en este lote. Empieza con un muestreo.')),
                      ],
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      itemCount: _items.length + (_loading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _items.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final item = _items[index];
                        final current = DateTime.parse(item['occurred_at'] as String).toLocal();
                        final previous = index == 0
                            ? null
                            : DateTime.parse(_items[index - 1]['occurred_at'] as String).toLocal();
                        final showMonth = previous == null ||
                            previous.year != current.year || previous.month != current.month;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showMonth)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 14, 8, 6),
                                child: Text(
                                  DateFormat('MMMM y', 'es').format(current),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            _TimelineTile(
                              item: item,
                              onTap: () => _open(item),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
      ],
    ),
  );

  void _open(Map<String, dynamic> item) {
    final ref = item['ref'] as Map<String, dynamic>? ?? {};
    switch (item['type']) {
      case 'care':
        context.push(AppRoutes.careDetailPath(widget.plotId, ref['id'] as String));
        break;
      case 'report':
        context.push(
          AppRoutes.reportsPath(widget.plotId),
          extra: ref['id'] as String,
        );
        break;
      case 'sample':
        context.push(AppRoutes.plotDetailPath(widget.plotId));
        break;
      case 'diagnosis':
        final ids = (item['data']?['diagnosis_ids'] as List?) ?? const [];
        if (ids.isNotEmpty) context.push(AppRoutes.diagnosisDetailPath(ids.first.toString()));
        break;
      case 'harvest':
      case 'loss':
        _showDetails(item);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El detalle de este registro todavía no está disponible.')),
        );
        break;
    }
  }

  void _showDetails(Map<String, dynamic> item) {
    final data = item['data'] as Map<String, dynamic>? ?? {};
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['title'] as String? ?? 'Detalle', style: Theme.of(context).textTheme.titleLarge),
              if (item['subtitle'] != null) ...[
                const SizedBox(height: 8),
                Text(item['subtitle'].toString()),
              ],
              for (final entry in data.entries)
                if (entry.value != null &&
                    !{'diagnosis_ids', 'disease_code'}.contains(entry.key))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${entry.key.replaceAll('_', ' ')}: ${entry.value}'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = item['type'] as String? ?? 'sample';
    final occurred = DateTime.parse(item['occurred_at'] as String).toLocal();
    final severity = item['severity'] as String?;
    final data = item['data'] as Map<String, dynamic>? ?? {};
    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 58,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(DateFormat('d MMM', 'es').format(occurred), style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
            SizedBox(
              width: 30,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 14),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _color(type),
                      shape: BoxShape.circle,
                      border: severity == 'high' ? Border.all(color: Colors.red, width: 3) : null,
                    ),
                  ),
                  Expanded(child: Container(width: 2, color: Theme.of(context).dividerColor)),
                ],
              ),
            ),
            Expanded(
              child: Card(
                margin: const EdgeInsets.only(bottom: 8, right: 6),
                child: ListTile(
                  leading: Icon(_icon(type), color: _color(type)),
                  title: Text(item['title'] as String? ?? _eventTypes[type] ?? 'Actividad'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item['subtitle'] != null) Text(item['subtitle'].toString()),
                      if (data['first_detection'] == true)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Primera detección', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String type) => switch (type) {
    'sample' => Icons.search,
    'diagnosis' => Icons.eco_outlined,
    'care' => Icons.medication_outlined,
    'harvest' => Icons.shopping_basket_outlined,
    'loss' => Icons.trending_down,
    'report' => Icons.picture_as_pdf_outlined,
    _ => Icons.circle_outlined,
  };

  Color _color(String type) => switch (type) {
    'diagnosis' => Colors.deepOrange,
    'care' => Colors.blue,
    'harvest' => Colors.green,
    'loss' => Colors.red,
    'report' => Colors.purple,
    _ => Colors.teal,
  };
}
