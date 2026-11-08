import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/refresh/plot_data_refresh.dart';
import 'package:kroppi/core/utils/number_format.dart';
import 'package:kroppi/core/widgets/decimal_field.dart';
import 'package:kroppi/core/widgets/module_states.dart';
import 'package:kroppi/core/widgets/primary_button.dart';

import '../../domain/entities/loss_estimation.dart';
import '../cubit/loss_form_cubit.dart';
import '../utils/loss_rules.dart';

/// Nueva estimación (sin id) o detalle/edición (con id). El resultado lo
/// calcula el backend: la pantalla solo formatea.
class LossFormScreen extends StatefulWidget {
  const LossFormScreen({super.key, required this.plotId});

  final String plotId;

  @override
  State<LossFormScreen> createState() => _LossFormScreenState();
}

class _LossFormScreenState extends State<LossFormScreen> {
  final _expected = TextEditingController();
  final _price = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _from;
  DateTime? _to;
  String _currency = 'COP';
  String? _expectedHelp;
  bool _filled = false;
  bool _dirty = false;

  LossFormCubit get _cubit => context.read<LossFormCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  void dispose() {
    _expected.dispose();
    _price.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _fillFromDefaults(LossDefaults defaults) {
    _filled = true;
    _from = defaults.periodFrom;
    _to = defaults.periodTo;
    _expected.text = DecimalInputFormatter.fromNumber(defaults.expectedYieldKg);
    _price.text = DecimalInputFormatter.fromNumber(defaults.pricePerKg);
    _currency = defaults.currency;
    _expectedHelp = defaults.expectedYieldKg == null
        ? null
        : 'Sugerido: promedio del cultivo × área del lote';
  }

  void _fillFromEstimation(LossEstimation estimation) {
    _filled = true;
    _from = estimation.periodFrom;
    _to = estimation.periodTo;
    _expected.text = DecimalInputFormatter.fromNumber(
      estimation.expectedYieldKg,
    );
    _price.text = DecimalInputFormatter.fromNumber(estimation.pricePerKg);
    _currency = estimation.currency;
    _notes.text = estimation.notes ?? '';
  }

  /// Entradas actuales, o null si alguna es inválida.
  LossInput? get _input {
    if (validateLossPeriod(_from, _to) != null ||
        validateExpectedKg(_expected.text) != null ||
        validateRequiredPrice(_price.text) != null) {
      return null;
    }
    return LossInput(
      expectedYieldKg: parseDecimal(_expected.text)!,
      pricePerKg: parseDecimal(_price.text)!,
      currency: _currency,
      periodFrom: _from!,
      periodTo: _to!,
      notes: _notes.text,
    );
  }

  void _changed() {
    setState(() => _dirty = true);
    _cubit.inputChanged(_input);
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final current = isFrom ? _from : _to;
    final value = await showDatePicker(
      context: context,
      initialDate: current ?? today(),
      firstDate: DateTime(2000),
      lastDate: DateTime(today().year + 2, 12, 31),
    );
    if (value == null) return;
    if (isFrom) {
      _from = value;
    } else {
      _to = value;
    }
    _changed();
  }

  void _save() {
    final input = _input;
    if (input != null) _cubit.save(input);
  }

  Future<void> _delete() async {
    if (await confirmDelete(context, '¿Eliminar esta estimación?')) {
      await _cubit.delete();
    }
  }

  void _listener(BuildContext context, LossFormState state) {
    if (state.status == LossFormStatus.ready && !_filled) {
      setState(() {
        if (state.estimation != null) {
          _fillFromEstimation(state.estimation!);
        } else if (state.defaults != null) {
          _fillFromDefaults(state.defaults!);
        }
      });
      _cubit.inputChanged(_input);
    }
    if (state.status == LossFormStatus.saved ||
        state.status == LossFormStatus.deleted) {
      PlotDataRefreshNotifier.instance.plotChanged(widget.plotId);
      setState(() => _dirty = false);
      context.pop(true);
    }
    final failure = state.saveFailure;
    if (failure != null && !handleCommonFailure(context, failure)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
    final loadFailure = state.loadFailure;
    if (loadFailure != null) handleCommonFailure(context, loadFailure);
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<LossFormCubit, LossFormState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.saveFailure != current.saveFailure,
        listener: _listener,
        builder: (context, state) => PopScope(
          canPop: !_dirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await confirmDiscardChanges(context) && context.mounted) {
              setState(() => _dirty = false);
              context.pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                _cubit.isEditing
                    ? 'Estimación de pérdidas'
                    : 'Nueva estimación',
              ),
              actions: [
                if (_cubit.isEditing && state.estimation != null)
                  IconButton(
                    tooltip: 'Eliminar',
                    onPressed: state.isSaving ? null : _delete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            body: switch (state.status) {
              LossFormStatus.loading => const SkeletonList(count: 3),
              LossFormStatus.loadFailure => ModuleErrorView(
                message: state.loadFailure?.message ?? 'No se pudo cargar.',
                onRetry: _cubit.load,
              ),
              _ => _form(state),
            },
          ),
        ),
      );

  Widget _form(LossFormState state) {
    final periodError = validateLossPeriod(_from, _to);
    final futureWarning = futurePeriodWarning(_to);
    final dateError = state.periodConflict
        ? 'Este periodo se cruza con otra estimación'
        : null;
    final preview = state.preview;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final fields = [
                DateField(
                  label: 'Desde*',
                  value: _from,
                  errorText: dateError,
                  onTap: () => _pickDate(isFrom: true),
                ),
                DateField(
                  label: 'Hasta*',
                  value: _to,
                  errorText: dateError ?? (_from != null ? periodError : null),
                  onTap: () => _pickDate(isFrom: false),
                ),
              ];
              if (constraints.maxWidth < 420) {
                return Column(
                  children: [fields[0], const SizedBox(height: 12), fields[1]],
                );
              }
              return Row(
                children: [
                  Expanded(child: fields[0]),
                  const SizedBox(width: 12),
                  Expanded(child: fields[1]),
                ],
              );
            },
          ),
          if (futureWarning != null) _Warning(futureWarning),
          const SizedBox(height: 16),
          DecimalField(
            label: 'Kilos que espero producir*',
            controller: _expected,
            suffixText: 'kg',
            helperText: _expectedHelp,
            validator: validateExpectedKg,
            onChanged: (_) => _changed(),
          ),
          const SizedBox(height: 16),
          DecimalField(
            label: 'Precio por kg*',
            controller: _price,
            validator: validateRequiredPrice,
            onChanged: (_) => _changed(),
          ),
          const SizedBox(height: 12),
          const Text('Moneda*'),
          const SizedBox(height: 6),
          CurrencySelector(
            value: _currency,
            onChanged: (value) {
              _currency = value;
              _changed();
            },
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Kilos cosechados',
              helperText: preview == null
                  ? 'Se calcula con las cosechas del periodo'
                  : '${preview.harvestsInPeriod} cosechas en el periodo',
            ),
            child: Text(preview == null ? '—' : formatKg(preview.harvestedKg)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notes,
            maxLines: 3,
            onChanged: (_) => _changed(),
            decoration: const InputDecoration(labelText: 'Observaciones'),
          ),
          const SizedBox(height: 20),
          _ResultCard(
            preview: preview,
            loading: state.previewLoading,
            failure: state.previewFailure?.message,
            onRetry: _cubit.retryPreview,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            key: const Key('loss_save'),
            label: _cubit.isEditing ? 'Guardar cambios' : 'Guardar estimación',
            isLoading: state.isSaving,
            onPressed: _input != null && !state.isSaving ? _save : null,
          ),
        ],
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.warning.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.preview,
    required this.loading,
    required this.failure,
    required this.onRetry,
  });

  final LossEstimation? preview;
  final bool loading;
  final String? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final result = preview;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Resultado', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (failure != null) ...[
              Text(failure!, style: const TextStyle(color: AppColors.error)),
              TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
            if (result == null && failure == null)
              const Text('Completa los campos para calcular la pérdida.'),
            if (result != null) ...[
              if (!result.hasLoss) ...[
                const Text(
                  'No hay pérdidas respecto a lo esperado',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (result.surplusKg > 0)
                  Text(
                    'Se superó lo esperado en ${formatKg(result.surplusKg)}',
                  ),
              ] else
                Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    _Figure('Kg perdidos', formatKg(result.lostKg)),
                    _Figure(
                      '% de pérdida',
                      formatPct(result.lossPct),
                      color: lossSeverityColor(lossSeverity(result.lossPct)),
                    ),
                    _Figure(
                      'Monto perdido',
                      formatMoney(result.estimatedLossAmount, result.currency),
                    ),
                  ],
                ),
              for (final warning in result.warnings) _Warning(warning),
              if (result.explanation?.isNotEmpty ?? false) ...[
                const SizedBox(height: 10),
                Text(result.explanation!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      Text(
        value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
      ),
    ],
  );
}
