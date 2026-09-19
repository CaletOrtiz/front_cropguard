import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/core/utils/validators.dart';
import 'package:cropguard/navigation/app_routes.dart';
import 'package:cropguard/presentation/common/app_text_field.dart';
import 'package:cropguard/presentation/common/primary_button.dart';
import 'package:cropguard/presentation/screens/auth/widgets/auth_header.dart';
import 'package:cropguard/presentation/screens/auth/widgets/auth_switch_prompt.dart';
import 'package:cropguard/presentation/screens/auth/widgets/social_auth_section.dart';

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
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.createAccount,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      AppStrings.registerSubtitle,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: AppStrings.fullName,
                      controller: _nameController,
                      validator: Validators.fullName,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: AppStrings.email,
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: AppStrings.password,
                      controller: _passwordController,
                      validator: Validators.password,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: AppStrings.register,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 8),
                    AuthSwitchPrompt(
                      prompt: AppStrings.haveAccount,
                      actionLabel: AppStrings.signInLink,
                      onPressed: () => context.go(AppRoutes.login),
                    ),
                    const SizedBox(height: 16),
                    const SocialAuthSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
