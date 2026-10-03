import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/core/utils/validators.dart';
import 'package:cropguard/navigation/app_routes.dart';
import 'package:cropguard/presentation/screens/auth/widgets/auth_input_field.dart';
import 'package:cropguard/presentation/screens/auth/widgets/auth_screen_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: conectar con el servicio de autenticación
    // (_emailController.text.trim(), _passwordController.text)
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      formKey: _formKey,
      title: AppStrings.welcomeBack,
      subtitle: AppStrings.loginSubtitle,
      fields: [
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
      submitLabel: AppStrings.login,
      onSubmit: _submit,
      switchPrompt: AppStrings.noAccount,
      switchActionLabel: AppStrings.signUpLink,
      onSwitchPressed: () => context.go(AppRoutes.register),
      onGooglePressed: () {
        // TODO: autenticación con Google
      },
      // Sin botón de volver: el login es la puerta de entrada tras el splash.
    );
  }
}
