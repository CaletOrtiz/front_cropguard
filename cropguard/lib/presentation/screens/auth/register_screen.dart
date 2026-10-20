import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/core/utils/validators.dart';
import 'package:kroppi/navigation/app_routes.dart';
import 'package:kroppi/presentation/screens/auth/widgets/auth_input_field.dart';
import 'package:kroppi/presentation/screens/auth/widgets/auth_screen_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: conectar con el servicio de registro
    // (_nameController.text.trim(), _emailController.text.trim(), password)
    context.go(AppRoutes.home);
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
          label: AppStrings.password,
          icon: Icons.lock_outline_rounded,
          controller: _passwordController,
          validator: Validators.password,
          isPassword: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
      ],
      submitLabel: AppStrings.register,
      onSubmit: _submit,
      switchPrompt: AppStrings.haveAccount,
      switchActionLabel: AppStrings.signInLink,
      onSwitchPressed: () => context.go(AppRoutes.login),
      onGooglePressed: () {
        // TODO: autenticación con Google
      },
      onBack: _goBack,
    );
  }
}
