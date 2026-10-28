import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/core/network/supabase/supabase_client.dart'
    as app_supabase;
import 'package:kroppi/core/theme/app_theme.dart';
import 'package:kroppi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kroppi/features/auth/data/datasources/supabase_auth_service.dart';
import 'package:kroppi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kroppi/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kroppi/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:kroppi/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:kroppi/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:kroppi/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kroppi/features/crop_diagnosis/data/repositories/crop_diagnosis_repository_impl.dart';
import 'package:kroppi/features/crop_diagnosis/domain/usecases/analyze_crop_image_usecase.dart';
import 'package:kroppi/navigation/app_router.dart';

class KroppiApp extends StatelessWidget {
  const KroppiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryImpl(
      AuthRemoteDataSource(
        SupabaseAuthService(app_supabase.SupabaseClient.client),
      ),
    );
    final analyzeCropImageUsecase = AnalyzeCropImageUsecase(
      repository: CropDiagnosisRepositoryImpl(
        dioClient: Dio(BaseOptions(baseUrl: 'https://tu-backend-api.com')),
      ),
    );

    return RepositoryProvider<AnalyzeCropImageUsecase>.value(
      value: analyzeCropImageUsecase,
      child: BlocProvider(
        create: (context) => AuthBloc(
          signInWithGoogle: SignInWithGoogleUsecase(authRepository),
          signInWithEmail: SignInWithEmailUsecase(authRepository),
          signUpWithEmail: SignUpWithEmailUsecase(authRepository),
          getCurrentUser: GetCurrentUserUsecase(authRepository),
          signOut: SignOutUsecase(authRepository),
        ),
        child: MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            final isWideScreen = MediaQuery.of(context).size.width > 600;
            if (!isWideScreen || child == null) {
              return child ?? const SizedBox();
            }

            return ColoredBox(
              color: const Color(0xFFE5E5E5),
              child: Center(
                child: Container(
                  width: 390,
                  height: 844,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
