import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/refresh/plot_data_refresh.dart';
import 'package:kroppi/core/utils/number_format.dart';
import 'package:kroppi/core/widgets/decimal_field.dart';
import 'package:kroppi/core/widgets/module_states.dart';
import 'package:kroppi/core/widgets/primary_button.dart';
import 'package:kroppi/navigation/app_routes.dart';

import '../../domain/entities/harvest.dart';
import '../cubit/harvest_form_cubit.dart';
import '../utils/harvest_validators.dart';

/// Registrar (sin id) o ver/editar (con id) una cosecha.
class HarvestFormScreen extends StatefulWidget {
  const HarvestFormScreen({super.key, required this.plotId});

  final String plotId;

  @override
  State<HarvestFormScreen> createState() => _HarvestFormScreenState();
}

class _HarvestFormScreenState extends State<HarvestFormScreen> {
  final _quantity = TextEditingController();
  final _price = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = today();
  String _currency = 'COP';
  bool _currencyTouched = false;
  bool _filled = false;
  bool _dirty = false;

  HarvestFormCubit get _cubit => context.read<HarvestFormCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _fill(Harvest harvest) {
    _filled = true;
    _date = harvest.harvestedAt;
    _quantity.text = DecimalInputFormatter.fromNumber(harvest.quantityKg);
    _price.text = DecimalInputFormatter.fromNumber(harvest.pricePerKg);
    _currency = harvest.currency;
    _notes.text = harvest.notes ?? '';
  }

  void _changed() => setState(() => _dirty = true);

  bool get _hasPrice => parseDecimal(_price.text) != null;

  bool get _isValid =>
      validateHarvestDate(_date) == null &&
      validateHarvestQuantity(_quantity.text) == null &&
      validateOptionalPrice(_price.text) == null;

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: today(),
    );
    if (value != null) {
      setState(() {
        _date = value;
        _dirty = true;
      });
    }
  }

  void _save() {
    if (!_isValid) return;
    _cubit.save(
      HarvestInput(
        harvestedAt: _date,
        quantityKg: parseDecimal(_quantity.text)!,
        pricePerKg: parseDecimal(_price.text),
        currency: _currency,
        notes: _notes.text,
      ),
    );
  }

  Future<void> _delete() async {
    if (await confirmDelete(context, '¿Eliminar esta cosecha?')) {
      await _cubit.delete();
    }
  }

  Future<void> _onSaved(HarvestSaveResult result) async {
    PlotDataRefreshNotifier.instance.plotChanged(widget.plotId);
    _dirty = false;
    if (result.affectsEstimations.isNotEmpty) {
      final recalc = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Estimación de pérdidas afectada'),
          content: const Text(
            'Esta cosecha cae dentro de una estimación de pérdidas ya '
            'guardada. ¿Recalcularla?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Ahora no'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Recalcular'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (recalc == true) {
        context.pushReplacement(
          AppRoutes.lossDetailPath(
            widget.plotId,
            result.affectsEstimations.first,
          ),
        );
        return;
      }
    }
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HarvestFormCubit, HarvestFormState>(
      listener: (context, state) {
        if (state.status == HarvestFormStatus.ready &&
            state.harvest != null &&
            !_filled) {
          setState(() => _fill(state.harvest!));
        }
        if (!_cubit.isEditing && !_currencyTouched && !_filled) {
          _currency = state.lastCurrency;
        }
        if (state.status == HarvestFormStatus.saved && state.result != null) {
          _onSaved(state.result!);
        }
        if (state.status == HarvestFormStatus.deleted) {
          PlotDataRefreshNotifier.instance.plotChanged(widget.plotId);
          _dirty = false;
          context.pop(true);
        }
        final failure = state.failure;
        if (failure != null && !handleCommonFailure(context, failure)) {
          if (state.status != HarvestFormStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(failure.message)));
          }
        }
      },
      builder: (context, state) {
        final editing = _cubit.isEditing;
        return PopScope(
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
              title: Text(editing ? 'Cosecha' : 'Registrar cosecha'),
              actions: [
                if (editing && state.harvest != null)
                  IconButton(
                    tooltip: 'Eliminar',
                    onPressed: state.isSaving ? null : _delete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            body: switch (state.status) {
              HarvestFormStatus.loading => const SkeletonList(count: 3),
              HarvestFormStatus.failure => ModuleErrorView(
                message: state.failure?.message ?? 'No se pudo cargar.',
                onRetry: _cubit.load,
              ),
              _ => _form(state),
            },
          ),
        );
      },
    );
  }

  Widget _form(HarvestFormState state) {
    final quantity = parseDecimal(_quantity.text);
    final price = parseDecimal(_price.text);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DateField(
            label: 'Fecha de cosecha*',
            value: _date,
            errorText: validateHarvestDate(_date),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          DecimalField(
            label: 'Cantidad (kg)*',
            controller: _quantity,
            suffixText: 'kg',
            validator: validateHarvestQuantity,
            onChanged: (_) => _changed(),
          ),
          const SizedBox(height: 16),
          DecimalField(
            label: 'Precio por kg',
            controller: _price,
            helperText: 'Opcional',
            validator: validateOptionalPrice,
            onChanged: (_) => _changed(),
          ),
          const SizedBox(height: 12),
          const Text('Moneda del precio'),
          const SizedBox(height: 6),
          CurrencySelector(
            value: _currency,
            onChanged: _hasPrice
                ? (value) => setState(() {
                    _currency = value;
                    _currencyTouched = true;
                    _dirty = true;
                  })
                : null,
          ),
          if (quantity != null && quantity > 0 && price != null) ...[
            const SizedBox(height: 12),
            Text(
              'Valor estimado: ${formatMoney(quantity * price, _currency)}',
              key: const Key('harvest_value_preview'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _notes,
            maxLines: 4,
            onChanged: (_) => _changed(),
            decoration: const InputDecoration(labelText: 'Observaciones'),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            key: const Key('harvest_save'),
            label: _cubit.isEditing ? 'Guardar cambios' : 'Guardar cosecha',
            isLoading: state.isSaving,
            onPressed: _isValid && !state.isSaving ? _save : null,
          ),
        ],
      ),
    );
  }
}
