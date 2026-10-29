import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/widgets/app_dropdown_field.dart';
import 'package:kroppi/core/widgets/app_text_field.dart';
import 'package:kroppi/core/widgets/primary_button.dart';
import 'package:kroppi/features/auth/domain/entities/app_user.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_event.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_state.dart';
import 'package:kroppi/features/auth/presentation/utils/register_options.dart';
import 'package:kroppi/features/auth/presentation/utils/validators.dart';
import 'package:kroppi/features/profile/domain/entities/update_profile_params.dart';
import 'package:kroppi/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:kroppi/features/profile/presentation/utils/profile_strings.dart';
import 'package:kroppi/features/profile/presentation/widgets/user_avatar.dart';

/// "Datos personales": foto (de la galería), celular, municipio y profesión.
class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  static const _maxPhotoBytes = 5 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();

  AppUser? _user;
  String? _municipality;
  String _role = RegisterOptions.roleFarmer;

  XFile? _pickedFile;
  Uint8List? _pickedBytes;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      final user = state.user;
      _user = user;
      _phoneController.text = user.phoneNumber ?? '';
      _municipality = user.municipality;
      _role = user.role;
    }
    _phoneController.addListener(_refresh);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  /// Hay algo distinto a lo guardado: activa el botón "Guardar cambios".
  bool get _hasChanges {
    final user = _user;
    if (user == null) return false;
    return _pickedBytes != null ||
        Validators.normalizePhone(_phoneController.text) !=
            Validators.normalizePhone(user.phoneNumber) ||
        _municipality != user.municipality ||
        _role != user.role;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Abre el selector de fotos del sistema. No pide permisos propios: en
  /// Android 13+ usa el Photo Picker y en iOS el selector PHPicker, que solo
  /// dan acceso a la foto elegida.
  Future<void> _pickPhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return; // el usuario canceló
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.lengthInBytes > _maxPhotoBytes) {
        _showMessage(ProfileStrings.photoTooBig);
        return;
      }
      setState(() {
        _pickedFile = file;
        _pickedBytes = bytes;
      });
    } on PlatformException {
      if (mounted) _showMessage(ProfileStrings.galleryError);
    }
  }

  String _contentType(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  void _save() {
    final user = _user;
    if (user == null || !_formKey.currentState!.validate()) return;

    final bytes = _pickedBytes;
    final file = _pickedFile;

    context.read<EditProfileCubit>().save(
      UpdateProfileParams(
        phoneNumber: Validators.normalizePhone(_phoneController.text),
        municipality: _municipality!,
        role: _role,
        previousAvatarUrl: user.avatarUrl,
        avatar: (bytes == null || file == null)
            ? null
            : AvatarUpload(
                bytes: bytes,
                fileName: file.name,
                contentType: _contentType(file.name),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state.status == EditProfileStatus.success && state.user != null) {
          // Actualiza el perfil en toda la app (Perfil, Inicio, etc.).
          context.read<AuthBloc>().add(AuthUserUpdated(state.user!));
          _showMessage(ProfileStrings.saved);
          if (context.canPop()) context.pop();
        } else if (state.status == EditProfileStatus.failure) {
          _showMessage('${ProfileStrings.saveError}: ${state.message}');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(ProfileStrings.personalData)),
        body: SafeArea(
          child: user == null
              ? const Center(child: Text('Inicia sesión para ver tus datos'))
              : _buildForm(user),
        ),
      ),
    );
  }

  Widget _buildForm(AppUser user) {
    final isSaving = context.watch<EditProfileCubit>().state.isSaving;

    // Si el municipio guardado no está en la lista, se agrega para poder
    // mostrarlo sin romper el campo.
    final municipalities = [
      ...RegisterOptions.cesarMunicipalities,
      if (user.municipality != null &&
          !RegisterOptions.cesarMunicipalities.contains(user.municipality))
        user.municipality!,
    ];

    // ADMIN no se ofrece ni se cambia desde la app.
    final isAdmin = user.role == 'ADMIN';
    final roles = <String, String>{
      ...RegisterOptions.roles,
      if (isAdmin) 'ADMIN': user.roleLabel,
    };

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: isSaving ? null : _pickPhoto,
                  child: Stack(
                    children: [
                      UserAvatar(
                        size: 104,
                        bytes: _pickedBytes,
                        imageUrl: user.avatarUrl,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.photo_camera_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: isSaving ? null : _pickPhoto,
                  child: const Text(ProfileStrings.changePhoto),
                ),
                Text(
                  user.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (user.email.isNotEmpty)
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppTextField(
            label: ProfileStrings.phone,
            hint: ProfileStrings.phoneHint,
            controller: _phoneController,
            validator: Validators.phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          AppDropdownField<String>(
            label: ProfileStrings.municipality,
            hint: ProfileStrings.municipalityHint,
            value: _municipality,
            validator: Validators.municipality,
            onChanged: isSaving
                ? null
                : (value) => setState(() => _municipality = value),
            items: [
              for (final name in municipalities)
                DropdownMenuItem(value: name, child: Text(name)),
            ],
          ),
          const SizedBox(height: 16),
          AppDropdownField<String>(
            label: ProfileStrings.profession,
            value: roles.containsKey(_role) ? _role : null,
            validator: Validators.role,
            onChanged: (isSaving || isAdmin)
                ? null
                : (value) => setState(
                    () => _role = value ?? RegisterOptions.roleFarmer,
                  ),
            items: [
              for (final entry in roles.entries)
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            ],
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: ProfileStrings.save,
            isLoading: isSaving,
            onPressed: _hasChanges ? _save : null,
          ),
        ],
      ),
    );
  }
}
