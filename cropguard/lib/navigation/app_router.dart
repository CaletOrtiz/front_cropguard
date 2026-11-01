import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/network/supabase/supabase_client.dart'
    as app_supabase;
import 'package:kroppi/core/widgets/placeholder_screen.dart';
import 'package:kroppi/navigation/app_routes.dart';
import 'package:kroppi/navigation/presentation/shell/main_shell.dart';

// Auth
import 'package:kroppi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_state.dart';
import 'package:kroppi/features/auth/presentation/screens/splash/splash_screen.dart';
import 'package:kroppi/features/auth/presentation/screens/login_screen.dart';
import 'package:kroppi/features/auth/presentation/screens/register_screen.dart';

// Home, historial, perfil
import 'package:kroppi/features/home/presentation/screens/home_screen.dart';
import 'package:kroppi/features/history/presentation/screens/history_screen.dart';
import 'package:kroppi/features/history/presentation/screens/diagnosis_detail_screen.dart';
import 'package:kroppi/features/history/data/datasources/history_remote_data_source.dart';
import 'package:kroppi/features/history/data/repositories/history_repository_impl.dart';
import 'package:kroppi/features/history/domain/entities/diagnosis_record.dart';
import 'package:kroppi/features/history/domain/usecases/get_diagnosis_history_usecase.dart';
import 'package:kroppi/features/history/presentation/cubit/history_cubit.dart';
import 'package:kroppi/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:kroppi/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kroppi/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:kroppi/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:kroppi/features/profile/presentation/screens/personal_data_screen.dart';
import 'package:kroppi/features/profile/presentation/screens/profile_screen.dart';

// Diagnóstico
import 'package:kroppi/features/crop_diagnosis/domain/usecases/analyze_crop_image_usecase.dart';
import 'package:kroppi/features/crop_diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:kroppi/features/crop_diagnosis/presentation/screens/diagnosis_screen.dart';

// Guía estática
import 'package:kroppi/features/guide/presentation/screens/crops_screen.dart'
    as guide;
import 'package:kroppi/features/guide/presentation/screens/crop_detail_screen.dart'
    as guide_detail;

// Mis cultivos y muestreo
import 'package:kroppi/features/my_crops/data/datasources/my_crops_remote_data_source.dart';
import 'package:kroppi/features/my_crops/presentation/cubit/my_crops_cubit.dart';
import 'package:kroppi/features/my_crops/presentation/cubit/plot_detail_cubit.dart';
import 'package:kroppi/features/my_crops/presentation/screens/my_crops_screen.dart';
import 'package:kroppi/features/my_crops/presentation/screens/crop_form_screen.dart';
import 'package:kroppi/features/my_crops/presentation/screens/crop_detail_screen.dart'
    as my_crop_detail;
import 'package:kroppi/features/my_crops/presentation/screens/plot_form_screen.dart';
import 'package:kroppi/features/my_crops/presentation/screens/plot_detail_screen.dart';
import 'package:kroppi/features/sampling/presentation/cubit/sampling_cubit.dart';
import 'package:kroppi/features/sampling/presentation/screens/sampling_screen.dart';

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
              // Pestaña: Mis cultivos
              GoRoute(
                path: AppRoutes.crops,
                builder: (context, state) => BlocProvider(
                  create: (context) =>
                      MyCropsCubit(context.read<MyCropsRemoteDataSource>())
                        ..load(),
                  child: const MyCropsScreen(),
                ),
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

      // Diagnóstico suelto (sin lote)
      GoRoute(
        path: AppRoutes.diagnose,
        builder: (context, state) {
          final userId = state.extra as String? ?? 'id_usuario_default';
          return BlocProvider(
            create: (context) => DiagnosisBloc(
              analyzeCropImageUseCase: context.read<AnalyzeCropImageUsecase>(),
            ),
            child: DiagnosisScreen(userId: userId),
          );
        },
      ),

      // --- Cultivos y lotes del usuario ---
      // IMPORTANTE: cropNew va ANTES de cropDetail
      GoRoute(
        path: AppRoutes.cropNew,
        builder: (context, state) => const CropFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.cropDetail,
        builder: (context, state) => my_crop_detail.CropDetailScreen(
          cropId: state.pathParameters['cropId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.plotNew,
        builder: (context, state) =>
            PlotFormScreen(cropId: state.pathParameters['cropId']!),
      ),
      GoRoute(
        path: AppRoutes.plotDetail,
        builder: (context, state) {
          final plotId = state.pathParameters['plotId']!;
          return BlocProvider(
            create: (context) =>
                PlotDetailCubit(context.read<MyCropsRemoteDataSource>(), plotId)
                  ..load(),
            child: PlotDetailScreen(plotId: plotId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.sampling,
        builder: (context, state) {
          final plotId = state.pathParameters['plotId']!;
          // PlotDetailScreen envía SamplingArgs en `extra` (cultivo + nº de plantas)
          final extra = state.extra;
          final args = extra is SamplingArgs
              ? extra
              : SamplingArgs(cropSlug: extra is String ? extra : 'cafe');
          final auth = context.read<AuthBloc>().state;
          final userId = auth is AuthAuthenticated ? auth.user.id : '';
          return BlocProvider(
            create: (context) => SamplingCubit(
              plotId: plotId,
              cropSlug: args.cropSlug,
              userId: userId,
              target: args.target,
              maxPlants: args.plantCount,
              analyze: context.read<AnalyzeCropImageUsecase>(),
              source: context.read<MyCropsRemoteDataSource>(),
            ),
            child: SamplingScreen(plotId: plotId),
          );
        },
      ),

      // --- Guía estática (movida desde /crops) ---
      GoRoute(
        path: AppRoutes.guide,
        builder: (context, state) => const guide.CropsScreen(),
      ),
      GoRoute(
        path: AppRoutes.guideDetail,
        builder: (context, state) => guide_detail.CropDetailScreen(
          cropId: state.pathParameters['cropId']!,
        ),
      ),

      // --- Perfil, historial y utilidades ---
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
        path: AppRoutes.diagnosisDetail,
        builder: (context, state) => DiagnosisDetailScreen(
          diagnosisId: state.pathParameters['diagnosisId']!,
          record: state.extra as DiagnosisRecord?,
        ),
      ),
    ],
  );
}
