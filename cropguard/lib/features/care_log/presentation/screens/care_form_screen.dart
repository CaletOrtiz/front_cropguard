import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:kroppi/features/care_log/presentation/utils/care_labels.dart';
import 'package:kroppi/features/plot_modules/data/plot_modules_remote_data_source.dart';

class CareFormScreen extends StatefulWidget {
  const CareFormScreen({super.key, required this.plotId, this.initial});

  final String plotId;
  final Map<String, dynamic>? initial;

  @override
  State<CareFormScreen> createState() => _CareFormScreenState();
}

class _CareFormScreenState extends State<CareFormScreen> {
  final _key = GlobalKey<FormState>();
  final _source = PlotModulesRemoteDataSource();
  final _picker = ImagePicker();
  late DateTime _date;
  late String _type;
  String? _unit;
  String? _method;
  XFile? _evidence;
  bool _saving = false;

  late final _product = TextEditingController(
    text: widget.initial?['product_name'] as String?,
  );
  late final _activeIngredient = TextEditingController(
    text: widget.initial?['active_ingredient'] as String?,
  );
  late final _quantity = TextEditingController(
    text: widget.initial?['quantity']?.toString(),
  );
  late final _disease = TextEditingController(
    text: widget.initial?['target_disease_code'] as String?,
  );
  late final _cost = TextEditingController(
    text: widget.initial?['cost']?.toString(),
  );
  late final _notes = TextEditingController(
    text: widget.initial?['notes'] as String?,
  );

  @override
  void initState() {
    super.initState();
    _date =
        DateTime.tryParse(widget.initial?['applied_at'] as String? ?? '') ??
        DateTime.now();
    _type = widget.initial?['activity_type'] as String? ?? careTypes.keys.first;
    _unit = widget.initial?['quantity_unit'] as String?;
    _method = widget.initial?['application_method'] as String?;
  }

  @override
  void dispose() {
    _product.dispose();
    _activeIngredient.dispose();
    _quantity.dispose();
    _disease.dispose();
    _cost.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (value != null && mounted) setState(() => _date = value);
  }

  Future<void> _chooseImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (image != null && mounted) setState(() => _evidence = image);
  }

  String _apiError(Object error) {
    return apiErrorMessage(error);
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final initial = widget.initial;
    try {
      final item = await _source.saveCare(widget.plotId, {
        'applied_at': DateFormat('yyyy-MM-dd').format(_date),
        'activity_type': _type,
        'product_name': _product.text.trim().isEmpty
            ? null
            : _product.text.trim(),
        'active_ingredient': _activeIngredient.text.trim().isEmpty
            ? null
            : _activeIngredient.text.trim(),
        'quantity': _quantity.text.trim().isEmpty
            ? null
            : double.parse(_quantity.text),
        'quantity_unit': _quantity.text.trim().isEmpty ? null : _unit,
        'application_method': _method,
        'target_disease_code': _disease.text.trim().isEmpty
            ? null
            : _disease.text.trim(),
        'cost': _cost.text.trim().isEmpty ? null : double.parse(_cost.text),
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      }, id: initial?['id'] as String?);
      if (_evidence != null) {
        final uploaded = await _uploadEvidence(item['id'] as String);
        if (!uploaded) {
          if (mounted) context.pop(true);
          return;
        }
      }
      if (!mounted) return;
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_apiError(error))));
    }
  }

  Future<bool> _uploadEvidence(String careId) async {
    while (mounted) {
      try {
        await _source.uploadCareEvidence(careId, _evidence!.path);
        return true;
      } catch (error) {
        if (!mounted) return false;
        final retry = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cuidado guardado'),
            content: Text(
              'No se pudo subir la foto: ${_apiError(error)}. El registro del cuidado sí se guardó.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continuar sin foto'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Reintentar foto'),
              ),
            ],
          ),
        );
        if (retry != true) return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.initial == null ? 'Registrar cuidado' : 'Editar cuidado',
      ),
    ),
    body: SafeArea(
      child: Form(
        key: _key,
        child: Scrollbar(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de aplicación *'),
                subtitle: Text(DateFormat('d MMM y', 'es').format(_date)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _saving ? null : _chooseDate,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo de actividad *',
                ),
                items: careTypes.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 14),
              _text(_product, 'Producto utilizado'),
              _text(_activeIngredient, 'Ingrediente activo'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantity,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad aplicada',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final number = double.tryParse(value);
                        return number == null || number <= 0
                            ? 'Ingresa una cantidad mayor que cero'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(labelText: 'Unidad'),
                      items: const ['kg', 'g', 'L', 'mL', 'unit']
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _unit = value),
                      validator: (_) =>
                          _quantity.text.trim().isNotEmpty && _unit == null
                          ? 'Requerida'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _method,
                decoration: const InputDecoration(
                  labelText: 'Método de aplicación',
                ),
                items: careMethods.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _method = value),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _disease.text.isEmpty ? '' : _disease.text,
                decoration: const InputDecoration(
                  labelText: 'Enfermedad objetivo (opcional)',
                ),
                items: const [
                  DropdownMenuItem(value: '', child: Text('Ninguna')),
                  DropdownMenuItem(
                    value: 'roya_cafe',
                    child: Text('Roya del café'),
                  ),
                  DropdownMenuItem(value: 'phoma_cafe', child: Text('Phoma')),
                  DropdownMenuItem(
                    value: 'minador_cafe',
                    child: Text('Minador de la hoja'),
                  ),
                ],
                onChanged: (value) => _disease.text = value ?? '',
              ),
              const SizedBox(height: 14),
              _text(
                _cost,
                'Costo (COP)',
                decimal: true,
                validateNonNegative: true,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notes,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _saving ? null : _chooseImage,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(
                  _evidence?.name ?? 'Fotografía de evidencia (opcional)',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar cuidado'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _text(
    TextEditingController controller,
    String label, {
    bool decimal = false,
    bool validateNonNegative = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (!validateNonNegative || value == null || value.trim().isEmpty) {
          return null;
        }
        final number = double.tryParse(value);
        return number == null || number < 0
            ? 'Ingresa un valor igual o mayor que cero'
            : null;
      },
    ),
  );
}
