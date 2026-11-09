import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/core/network/api/fastapi_client.dart';
import 'package:kroppi/core/network/api/services/ai_backend_service.dart';
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
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/harvests/data/repositories/harvest_repository_impl.dart';
import 'package:kroppi/features/harvests/domain/repositories/harvest_repository.dart';
import 'package:kroppi/features/loss_estimation/data/repositories/loss_repository_impl.dart';
import 'package:kroppi/features/loss_estimation/domain/repositories/loss_repository.dart';
import 'package:kroppi/features/my_crops/data/datasources/my_crops_remote_data_source.dart';
import 'package:kroppi/features/profile/data/datasources/premium_checkout_remote_data_source.dart';
import 'package:kroppi/features/profile/data/repositories/premium_checkout_repository_impl.dart';
import 'package:kroppi/features/profile/domain/usecases/create_premium_checkout_usecase.dart';
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
      repository: CropDiagnosisRepositoryImpl(dioClient: FastApiClient.client),
    );
    final getCurrentUser = GetCurrentUserUsecase(authRepository);
    final createPremiumCheckout = CreatePremiumCheckoutUsecase(
      PremiumCheckoutRepositoryImpl(
        PremiumCheckoutRemoteDataSource(
          FastApiClient.client,
          app_supabase.SupabaseClient.client,
        ),
      ),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GetCurrentUserUsecase>.value(value: getCurrentUser),
        RepositoryProvider<CreatePremiumCheckoutUsecase>.value(
          value: createPremiumCheckout,
        ),
        RepositoryProvider<AnalyzeCropImageUsecase>.value(
          value: analyzeCropImageUsecase,
        ),
        RepositoryProvider<MyCropsRemoteDataSource>.value(
          value: MyCropsRemoteDataSource(AiBackendService()),
        ),
        RepositoryProvider<FarmRemoteDataSource>(
          create: (_) =>
              FarmRemoteDataSource(app_supabase.SupabaseClient.client),
        ),
        RepositoryProvider<HarvestRepository>(
          create: (_) => HarvestRepositoryImpl(),
        ),
        RepositoryProvider<LossRepository>(create: (_) => LossRepositoryImpl()),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          signInWithGoogle: SignInWithGoogleUsecase(authRepository),
          signInWithEmail: SignInWithEmailUsecase(authRepository),
          signUpWithEmail: SignUpWithEmailUsecase(authRepository),
          getCurrentUser: getCurrentUser,
          signOut: SignOutUsecase(authRepository),
        ),
        child: MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          locale: const Locale('es'),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            final isWideScreen = MediaQuery.of(context).size.width > 600;
            if (!isWideScreen || child == null) {
              return child ?? const SizedBox();
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final frameSize = constraints.constrain(const Size(390, 844));
                return ColoredBox(
                  color: const Color(0xFFE5E5E5),
                  child: Center(
                    child: Container(
                      width: frameSize.width,
                      height: frameSize.height,
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
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(size: frameSize),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
