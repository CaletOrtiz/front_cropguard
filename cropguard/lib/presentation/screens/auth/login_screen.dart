import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/core/utils/validators.dart';
import 'package:cropguard/navigation/app_routes.dart';
import 'package:cropguard/features/auth/domain/usescases/sign_in_with_google_usecase.dart';
import 'package:cropguard/presentation/screens/auth/widgets/auth_input_field.dart';
import 'package:cropguard/presentation/screens/auth/widgets/auth_screen_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.signInWithGoogle});

  final SignInWithGoogleUsecase signInWithGoogle;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isGoogleSignInLoading = false;

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

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleSignInLoading = true);
    try {
      await widget.signInWithGoogle();
      if (mounted) context.go(AppRoutes.home);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('No se pudo iniciar sesión: $error')));
    } finally {
      if (mounted) setState(() => _isGoogleSignInLoading = false);
    }
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
      onGooglePressed: _isGoogleSignInLoading ? null : _signInWithGoogle,
      isGoogleLoading: _isGoogleSignInLoading,
      // Sin botón de volver: el login es la puerta de entrada tras el splash.
    );
  }
}
