import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/core/widgets/app_text_field.dart';
import 'package:kroppi/core/widgets/primary_button.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';

class FarmFormScreen extends StatefulWidget {
  const FarmFormScreen({super.key, this.farmId});

  final String? farmId;

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _areaHa = TextEditingController();
  final _description = TextEditingController();
  final _department = TextEditingController();
  final _municipality = TextEditingController();
  final _address = TextEditingController();
  bool _loading = false;
  bool _saving = false;
  String? _loadError;

  bool get _isEditing => widget.farmId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadFarm());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _areaHa.dispose();
    _description.dispose();
    _department.dispose();
    _municipality.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _loadFarm() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final farm = await context.read<FarmRemoteDataSource>().getFarm(
        widget.farmId!,
      );
      if (!mounted) return;
      _name.text = farm.name;
      _areaHa.text = farm.areaHa?.toString() ?? '';
      _description.text = farm.description ?? '';
      _department.text = farm.department ?? '';
      _municipality.text = farm.municipality ?? '';
      _address.text = farm.address ?? '';
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = error.toString();
      });
    }
  }

  String? _validateArea(String? value) {
    final area = _parseNumber(value);
    if (area == null || !area.isFinite || area <= 0) {
      return 'Ingresa un área mayor que 0.';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final source = context.read<FarmRemoteDataSource>();
      final name = _name.text.trim();
      final areaHa = _parseNumber(_areaHa.text)!;
      if (_isEditing) {
        await source.updateFarm(
          farmId: widget.farmId!,
          name: name,
          areaHa: areaHa,
          description: _description.text,
          department: _department.text,
          municipality: _municipality.text,
          address: _address.text,
        );
      } else {
        await source.createFarm(
          name: name,
          areaHa: areaHa,
          description: _description.text,
          department: _department.text,
          municipality: _municipality.text,
          address: _address.text,
        );
      }
      if (mounted) context.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
    }
  }

  double? _parseNumber(String? value) =>
      double.tryParse((value ?? '').trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar finca' : AppStrings.createFarm),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadError!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loadFarm,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text(
                      'Datos de la finca',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'El propietario se asigna automáticamente a tu cuenta.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Nombre de la finca',
                      hint: 'Ej. La Esperanza',
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Ingresa el nombre de la finca.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Área total (ha)',
                      hint: 'Ej. 12.5',
                      controller: _areaHa,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _validateArea,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Descripción (opcional)',
                      hint: 'Información adicional sobre la finca',
                      controller: _description,
                      textInputAction: TextInputAction.next,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Departamento (opcional)',
                      controller: _department,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Municipio (opcional)',
                      controller: _municipality,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Dirección o vereda (opcional)',
                      controller: _address,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: _isEditing ? 'Guardar cambios' : 'Guardar finca',
                      isLoading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
