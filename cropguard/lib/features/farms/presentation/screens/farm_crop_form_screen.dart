import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/widgets/app_dropdown_field.dart';
import 'package:kroppi/core/widgets/app_text_field.dart';
import 'package:kroppi/core/widgets/primary_button.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/farms/domain/entities/farm_details.dart';
import 'package:kroppi/features/history/presentation/utils/date_formatter.dart';

class FarmCropFormScreen extends StatefulWidget {
  const FarmCropFormScreen({super.key, required this.farmId, this.cropId});

  final String farmId;
  final String? cropId;

  @override
  State<FarmCropFormScreen> createState() => _FarmCropFormScreenState();
}

class _FarmCropFormScreenState extends State<FarmCropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  List<Map<String, dynamic>> _types = [];
  String? _typeId;
  DateTime? _plantedAt;
  DateTime? _expectedHarvestAt;
  bool _isActive = true;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  bool get _isEditing => widget.cropId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final source = context.read<FarmRemoteDataSource>();
      final types = await source.getCropTypes();
      FarmCrop? crop;
      if (_isEditing) crop = await source.getFarmCrop(widget.cropId!);
      if (!mounted) return;
      if (crop != null && !types.any((type) => type['id'] == crop!.cropTypeId)) {
        types.add({'id': crop.cropTypeId, 'name': crop.typeName});
      }
      if (types.isEmpty) {
        throw StateError('No hay tipos de cultivo disponibles para registrar.');
      }
      setState(() {
        _types = types;
        _typeId = crop?.cropTypeId ?? (types.length == 1 ? types.first['id'] as String : null);
        _name.text = crop?.name ?? '';
        _plantedAt = crop?.plantedAt;
        _expectedHarvestAt = crop?.expectedHarvestAt;
        _isActive = crop?.isActive ?? true;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = error.toString();
      });
    }
  }

  Future<void> _pickDate({required bool planted}) async {
    final now = DateTime.now();
    final current = planted ? _plantedAt : _expectedHarvestAt;
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 30),
      lastDate: DateTime(now.year + 10),
    );
    if (date == null || !mounted) return;
    setState(() {
      if (planted) {
        _plantedAt = date;
      } else {
        _expectedHarvestAt = date;
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (_plantedAt != null &&
        _expectedHarvestAt != null &&
        _expectedHarvestAt!.isBefore(_plantedAt!)) {
      _showMessage('La cosecha estimada no puede ser anterior a la siembra.');
      return;
    }
    setState(() => _saving = true);
    try {
      final source = context.read<FarmRemoteDataSource>();
      final name = _name.text.trim();
      if (_isEditing) {
        await source.updateCrop(
          cropId: widget.cropId!,
          cropTypeId: _typeId!,
          name: name,
          isActive: _isActive,
          plantedAt: _plantedAt,
          expectedHarvestAt: _expectedHarvestAt,
        );
      } else {
        await source.createCrop(
          farmId: widget.farmId,
          cropTypeId: _typeId!,
          name: name,
          isActive: _isActive,
          plantedAt: _plantedAt,
          expectedHarvestAt: _expectedHarvestAt,
        );
      }
      if (mounted) context.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('No se pudo guardar el cultivo: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar cultivo' : 'Agregar cultivo'),
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
                        onPressed: _load,
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
                    AppDropdownField<String>(
                      label: 'Tipo de cultivo',
                      hint: 'Selecciona uno',
                      value: _typeId,
                      validator: (value) =>
                          value == null ? 'Selecciona el tipo de cultivo.' : null,
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _typeId = value),
                      items: [
                        for (final type in _types)
                          DropdownMenuItem(
                            value: type['id'] as String,
                            child: Text(type['name'] as String),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nombre del cultivo',
                      hint: 'Ej. Café La Esperanza',
                      controller: _name,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Ingresa un nombre.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _DateField(
                      label: 'Fecha de siembra (opcional)',
                      value: _plantedAt,
                      onTap: () => _pickDate(planted: true),
                      onClear: () => setState(() => _plantedAt = null),
                    ),
                    const SizedBox(height: 16),
                    _DateField(
                      label: 'Cosecha estimada (opcional)',
                      value: _expectedHarvestAt,
                      onTap: () => _pickDate(planted: false),
                      onClear: () => setState(() => _expectedHarvestAt = null),
                    ),
                    if (_isEditing)
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Cultivo activo'),
                        value: _isActive,
                        activeTrackColor: AppColors.primary,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _isActive = value),
                      ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: _isEditing ? 'Guardar cambios' : 'Guardar cultivo',
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
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value == null ? 'Seleccionar fecha' : DateFormatter.short(value!),
                ),
              ),
              if (value != null)
                IconButton(
                  onPressed: onClear,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded),
                )
              else
                const Icon(Icons.calendar_today_outlined, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
