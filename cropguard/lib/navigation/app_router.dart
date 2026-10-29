import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/core/network/supabase/supabase_client.dart'
    as app_supabase;
import 'package:go_router/go_router.dart';
import 'package:kroppi/navigation/app_routes.dart';
import 'package:kroppi/core/widgets/placeholder_screen.dart';
import 'package:kroppi/features/auth/presentation/screens/splash/splash_screen.dart';
import 'package:kroppi/features/auth/presentation/screens/login_screen.dart';
import 'package:kroppi/features/auth/presentation/screens/register_screen.dart';
import 'package:kroppi/features/home/presentation/screens/home_screen.dart';
import 'package:kroppi/navigation/presentation/shell/main_shell.dart';
import 'package:kroppi/features/history/presentation/screens/history_screen.dart';
import 'package:kroppi/features/crops/presentation/screens/crops_screen.dart';
import 'package:kroppi/features/crops/presentation/screens/crop_detail_screen.dart';
import 'package:kroppi/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:kroppi/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kroppi/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:kroppi/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:kroppi/features/profile/presentation/screens/personal_data_screen.dart';
import 'package:kroppi/features/profile/presentation/screens/profile_screen.dart';
import 'package:kroppi/features/history/presentation/screens/diagnosis_detail_screen.dart';
import 'package:kroppi/features/crop_diagnosis/domain/usecases/analyze_crop_image_usecase.dart';
import 'package:kroppi/features/crop_diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:kroppi/features/crop_diagnosis/presentation/screens/diagnosis_screen.dart';
import 'package:kroppi/features/history/data/datasources/history_remote_data_source.dart';
import 'package:kroppi/features/history/data/repositories/history_repository_impl.dart';
import 'package:kroppi/features/history/domain/entities/diagnosis_record.dart';
import 'package:kroppi/features/history/domain/usecases/get_diagnosis_history_usecase.dart';
import 'package:kroppi/features/history/presentation/cubit/history_cubit.dart';

class AppRouter {
  AppRouter._();
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
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
                builder: (context, state) => BlocProvider(
                  create: (_) => HistoryCubit(
                    GetDiagnosisHistoryUsecase(
                      HistoryRepositoryImpl(
                        HistoryRemoteDataSource(
                          app_supabase.SupabaseClient.client,
                        ),
                      ),
                    ),
                  )..load(),
                  child: const HistoryScreen(),
                ),
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
              analyzeCropImageUseCase: context.read<AnalyzeCropImageUsecase>(),
            ),
            child: DiagnosisScreen(userId: userId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.personalData,
        builder: (context, state) => BlocProvider(
          create: (_) => EditProfileCubit(
            UpdateProfileUsecase(
              ProfileRepositoryImpl(
                ProfileRemoteDataSource(app_supabase.SupabaseClient.client),
              ),
            ),
          ),
          child: const PersonalDataScreen(),
        ),
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
          record: state.extra as DiagnosisRecord?,
        ),
      ),
    ],
  );
}
