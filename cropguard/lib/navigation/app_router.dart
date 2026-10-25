import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/navigation/app_routes.dart';
import 'package:kroppi/presentation/common/placeholder_screen.dart';
import 'package:kroppi/presentation/screens/splash/splash_screen.dart';
import 'package:kroppi/presentation/screens/auth/login_screen.dart';
import 'package:kroppi/presentation/screens/auth/register_screen.dart';
import 'package:kroppi/presentation/screens/home/home_screen.dart';
import 'package:kroppi/presentation/screens/shell/main_shell.dart';
import 'package:kroppi/presentation/screens/history/history_screen.dart';
import 'package:kroppi/presentation/screens/crops/crops_screen.dart';
import 'package:kroppi/presentation/screens/crops/crop_detail_screen.dart';
import 'package:kroppi/presentation/screens/profile/profile_screen.dart';
import 'package:kroppi/presentation/screens/history/diagnosis_detail_screen.dart';
import 'package:kroppi/core/network/supabase/supabase_auth_service.dart';
import 'package:kroppi/core/network/supabase/supabase_client.dart'
    as app_supabase;
import 'package:kroppi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kroppi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kroppi/features/auth/domain/usescases/sign_in_with_google_usecase.dart';

import '../features/crop_diagnosis/data/repositories/crop_diagnosis_repository_impl.dart';
import '../features/crop_diagnosis/domain/usecases/analyze_crop_image_usecase.dart';
import '../features/crop_diagnosis/presentation/bloc/diagnosis_bloc.dart';
import '../features/crop_diagnosis/presentation/screen/diagnosis_screen.dart';

class AppRouter {
  AppRouter._();
  // Creamos la instancia con la 'c' minúscula exactamente como la llamaste en tu clase:
  static final Dio _dioClient = Dio(
    BaseOptions(baseUrl: 'https://tu-backend-api.com'),
  );

  // 2. Instancia del Repositorio (debes importar crop_diagnosis_repository_impl.dart)
  static final CropDiagnosisRepositoryImpl _diagnosisRepository =
      CropDiagnosisRepositoryImpl(dioClient: _dioClient);

  // 3. Instancia del Caso de Uso (AQUÍ USAS LA VARIABLE DECLARADA ARRIBA)
  static final AnalyzeCropImageUsecase _analyzeCropImageUsecase =
      AnalyzeCropImageUsecase(repository: _diagnosisRepository);
  static final SignInWithGoogleUsecase _signInWithGoogleUsecase =
      SignInWithGoogleUsecase(
        AuthRepositoryImpl(
          AuthRemoteDataSource(
            SupabaseAuthService(app_supabase.SupabaseClient.client),
          ),
        ),
      );

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            LoginScreen(signInWithGoogle: _signInWithGoogleUsecase),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) =>
            RegisterScreen(signInWithGoogle: _signInWithGoogleUsecase),
      ),

      // Pestañas con barra de navegación inferior
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.crops,
                builder: (context, state) => const CropsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Fuera de la barra inferior (a pantalla completa)
      GoRoute(
        path: AppRoutes.diagnose, // Corresponde al string '/diagnose'
        builder: (context, state) {
          // Si pasaste el userId mediante context.push(AppRoutes.diagnose, extra: userId)
          final userId = state.extra as String? ?? 'id_usuario_default';

          return BlocProvider(
            create: (context) => DiagnosisBloc(
              analyzeCropImageUseCase:
                  _analyzeCropImageUsecase, // Tu instancia de UseCase
            ),
            child: DiagnosisScreen(userId: userId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Notificaciones'),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Ayuda y soporte'),
      ),
      GoRoute(
        path: AppRoutes.cropDetail,
        builder: (context, state) =>
            CropDetailScreen(cropId: state.pathParameters['cropId']!),
      ),
      GoRoute(
        path: AppRoutes.diagnosisDetail,
        builder: (context, state) => DiagnosisDetailScreen(
          diagnosisId: state.pathParameters['diagnosisId']!,
        ),
      ),
    ],
  );
}
