import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/features/auth/domain/entities/sign_up_params.dart';
import 'package:kroppi/features/auth/presentation/utils/register_options.dart';
import 'package:kroppi/features/auth/presentation/utils/validators.dart';
import 'package:kroppi/navigation/app_routes.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_event.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_state.dart';
import 'package:kroppi/features/auth/presentation/widgets/auth_dropdown_field.dart';
import 'package:kroppi/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:kroppi/features/auth/presentation/widgets/auth_screen_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _municipality;
  String _role = RegisterOptions.roleFarmer;

  /// Para que el spinner salga en el botón que se tocó.
  bool _googleTapped = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _busy => context.read<AuthBloc>().state is AuthLoading;

  void _submit() {
    if (_busy || !_formKey.currentState!.validate()) return;
    _googleTapped = false;
    context.read<AuthBloc>().add(
      AuthEmailSignUpRequested(
        SignUpParams(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phoneNumber: Validators.normalizePhone(_phoneController.text),
          municipality: _municipality,
          department: RegisterOptions.department,
          role: _role,
        ),
      ),
    );
  }

  void _signInWithGoogle() {
    if (_busy) return;
    setState(() => _googleTapped = true);
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state case AuthSignUpConfirmationRequired(:final email)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 7),
                content: Text(
                  'Te enviamos un correo a $email. Confírmalo y luego inicia sesión.',
                ),
              ),
            );
          context.go(AppRoutes.login);
        } else if (state case AuthFailure(:final message)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('No se pudo crear la cuenta: $message')),
            );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return AuthScreenLayout(
          formKey: _formKey,
          title: AppStrings.createAccount,
          subtitle: AppStrings.registerSubtitle,
          fields: [
            AuthInputField(
              label: AppStrings.fullName,
              icon: Icons.person_outline_rounded,
              controller: _nameController,
              validator: Validators.fullName,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            AuthInputField(
              label: AppStrings.email,
              icon: Icons.mail_outline_rounded,
              controller: _emailController,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            AuthInputField(
              label: RegisterOptions.phoneLabel,
              icon: Icons.phone_outlined,
              controller: _phoneController,
              validator: Validators.phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            AuthDropdownField<String>(
              label: RegisterOptions.municipalityLabel,
              hint: 'Selecciona tu municipio',
              icon: Icons.location_on_outlined,
              value: _municipality,
              validator: Validators.municipality,
              onChanged: (value) => setState(() => _municipality = value),
              items: [
                for (final name in RegisterOptions.cesarMunicipalities)
                  DropdownMenuItem(value: name, child: Text(name)),
              ],
            ),
            AuthDropdownField<String>(
              label: RegisterOptions.roleLabel,
              icon: Icons.badge_outlined,
              value: _role,
              validator: Validators.role,
              onChanged: (value) =>
                  setState(() => _role = value ?? RegisterOptions.roleFarmer),
              items: [
                for (final entry in RegisterOptions.roles.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
            ),
            AuthInputField(
              label: AppStrings.password,
              icon: Icons.lock_outline_rounded,
              controller: _passwordController,
              validator: Validators.password,
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ],
          submitLabel: isLoading && !_googleTapped
              ? RegisterOptions.registering
              : AppStrings.register,
          onSubmit: _submit,
          switchPrompt: AppStrings.haveAccount,
          switchActionLabel: AppStrings.signInLink,
          onSwitchPressed: () => context.go(AppRoutes.login),
          onGooglePressed: isLoading ? null : _signInWithGoogle,
          isGoogleLoading: isLoading && _googleTapped,
          onBack: _goBack,
        );
      },
    );
  }
}
