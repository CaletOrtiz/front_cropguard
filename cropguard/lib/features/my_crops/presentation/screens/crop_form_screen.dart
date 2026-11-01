import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/widgets/app_dropdown_field.dart';
import 'package:kroppi/core/widgets/app_text_field.dart';
import 'package:kroppi/core/widgets/primary_button.dart';
import 'package:kroppi/features/history/presentation/utils/date_formatter.dart';
import 'package:kroppi/features/my_crops/data/datasources/my_crops_remote_data_source.dart';

class CropFormScreen extends StatefulWidget {
  const CropFormScreen({super.key});

  @override
  State<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends State<CropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  List<Map<String, dynamic>> _types = [];
  String? _typeId;
  DateTime? _planted;
  DateTime? _harvest;
  bool _loadingTypes = true;
  bool _saving = false;
  String? _loadError;

  MyCropsRemoteDataSource get _source =>
      context.read<MyCropsRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTypes());
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _loadTypes() async {
    try {
      final types = await _source.getCropTypes();
      if (!mounted) return;
      setState(() {
        _types = types;
        _loadingTypes = false;
        if (types.length == 1) _typeId = types.first['id'] as String;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingTypes = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _pickDate(bool planted) async {
    final now = DateTime.now();
    final initial = (planted ? _planted : _harvest) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 30),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() => planted ? _planted = picked : _harvest = picked);
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (_planted != null && _harvest != null && _harvest!.isBefore(_planted!)) {
      _msg('La cosecha estimada no puede ser anterior a la siembra.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _source.createCrop(
        cropTypeId: _typeId!,
        name: _name.text.trim(),
        plantedAt: _planted,
        expectedHarvestAt: _harvest,
      );
      if (mounted) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _msg('No se pudo guardar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar cultivo')),
      body: SafeArea(
        child: _loadingTypes
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_loadError!, textAlign: TextAlign.center),
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    AppDropdownField<String>(
                      label: 'Tipo de cultivo',
                      hint: 'Selecciona uno',
                      value: _typeId,
                      validator: (v) => v == null ? 'Selecciona el tipo' : null,
                      onChanged: _saving
                          ? null
                          : (v) => setState(() => _typeId = v),
                      items: [
                        for (final t in _types)
                          DropdownMenuItem(
                            value: t['id'] as String,
                            child: Text(t['name'] as String),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nombre del cultivo',
                      hint: 'Ej. Café Finca La Esperanza',
                      controller: _name,
                      textInputAction: TextInputAction.done,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa un nombre'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _DateField(
                      label: 'Fecha de siembra (opcional)',
                      value: _planted,
                      onTap: () => _pickDate(true),
                      onClear: () => setState(() => _planted = null),
                    ),
                    const SizedBox(height: 16),
                    _DateField(
                      label: 'Cosecha estimada (opcional)',
                      value: _harvest,
                      onTap: () => _pickDate(false),
                      onClear: () => setState(() => _harvest = null),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Guardar cultivo',
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value == null
                        ? 'Seleccionar fecha'
                        : DateFormatter.short(value!),
                    style: TextStyle(
                      color: value == null
                          ? AppColors.textSecondary.withValues(alpha: 0.7)
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (value != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
