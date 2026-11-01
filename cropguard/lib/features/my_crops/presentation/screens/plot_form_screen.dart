import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/widgets/app_text_field.dart';
import 'package:kroppi/core/widgets/primary_button.dart';
import 'package:kroppi/features/my_crops/data/datasources/my_crops_remote_data_source.dart';

class PlotFormScreen extends StatefulWidget {
  const PlotFormScreen({super.key, required this.cropId});

  final String cropId;

  @override
  State<PlotFormScreen> createState() => _PlotFormScreenState();
}

class _PlotFormScreenState extends State<PlotFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _area = TextEditingController();
  final _plants = TextEditingController();
  final _variety = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    _plants.dispose();
    _variety.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<MyCropsRemoteDataSource>().createPlot(
        widget.cropId,
        name: _name.text.trim(),
        areaHa: double.parse(_area.text.trim().replaceAll(',', '.')),
        plantCount: int.tryParse(_plants.text.trim()),
        variety: _variety.text.trim(),
      );
      if (mounted) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo lote')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AppTextField(
                label: 'Nombre del lote',
                hint: 'Ej. Lote 1',
                controller: _name,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Área (hectáreas)',
                hint: 'Ej. 2.5',
                controller: _area,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final n = double.tryParse(
                    (v ?? '').trim().replaceAll(',', '.'),
                  );
                  if (n == null || n <= 0) return 'Ingresa un área válida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Número de plantas (opcional)',
                hint: 'Ej. 1200',
                controller: _plants,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  final n = int.tryParse(t);
                  return (n == null || n < 1) ? 'Número no válido' : null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Variedad (opcional)',
                hint: 'Ej. Castillo',
                controller: _variety,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Guardar lote',
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
