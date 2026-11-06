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
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/farms/domain/entities/farm_details.dart';
import 'package:kroppi/features/farms/presentation/cubit/farms_cubit.dart';
import 'package:kroppi/features/farms/presentation/screens/farm_form_screen.dart';
import 'package:kroppi/features/farms/presentation/screens/farm_detail_screen.dart';
import 'package:kroppi/features/farms/presentation/screens/farm_crop_form_screen.dart';
import 'package:kroppi/features/farms/presentation/screens/farm_crop_detail_screen.dart';
import 'package:kroppi/features/farms/presentation/screens/farm_plot_detail_screen.dart';
import 'package:kroppi/features/farms/presentation/screens/farms_screen.dart';
import 'package:kroppi/features/farms/presentation/screens/plots_overview_screen.dart';
import 'package:kroppi/features/home/presentation/cubit/home_cubit.dart';
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
import 'package:kroppi/features/my_crops/presentation/cubit/plot_detail_cubit.dart';
import 'package:kroppi/features/my_crops/presentation/screens/crop_form_screen.dart';
import 'package:kroppi/features/my_crops/presentation/screens/crop_detail_screen.dart'
    as my_crop_detail;
import 'package:kroppi/features/my_crops/presentation/screens/plot_form_screen.dart';
import 'package:kroppi/features/my_crops/presentation/screens/plot_detail_screen.dart';
import 'package:kroppi/features/sampling/presentation/cubit/sampling_cubit.dart';
import 'package:kroppi/features/sampling/presentation/screens/sampling_screen.dart';
import 'package:kroppi/features/care_log/presentation/screens/care_detail_screen.dart';
import 'package:kroppi/features/care_log/presentation/screens/care_form_screen.dart';
import 'package:kroppi/features/care_log/presentation/screens/care_list_screen.dart';
import 'package:kroppi/features/plot_stats/presentation/screens/plot_stats_screen.dart';
import 'package:kroppi/features/plot_timeline/presentation/screens/plot_timeline_screen.dart';
import 'package:kroppi/features/reports/presentation/screens/report_setup_screen.dart';
import 'package:kroppi/features/reports/presentation/screens/reports_list_screen.dart';

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
        builder: (context, state, navigationShell) => BlocProvider(
          create: (context) =>
              HomeCubit(context.read<FarmRemoteDataSource>())..load(),
          child: MainShell(navigationShell: navigationShell),
        ),
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
              // Pestaña: gestión de fincas
              GoRoute(
                path: AppRoutes.farms,
                builder: (context, state) => BlocProvider(
                  create: (context) =>
                      FarmsCubit(context.read<FarmRemoteDataSource>())..load(),
                  child: const FarmsScreen(),
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
      GoRoute(
        path: AppRoutes.farmNew,
        builder: (context, state) => const FarmFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmEdit,
        builder: (context, state) =>
            FarmFormScreen(farmId: state.pathParameters['farmId']!),
      ),
      GoRoute(
        path: AppRoutes.farmCropNew,
        builder: (context, state) =>
            FarmCropFormScreen(farmId: state.pathParameters['farmId']!),
      ),
      GoRoute(
        path: AppRoutes.farmCropDetail,
        builder: (context, state) => FarmCropDetailScreen(
          farmId: state.pathParameters['farmId']!,
          cropId: state.pathParameters['cropId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.farmCropEdit,
        builder: (context, state) => FarmCropFormScreen(
          farmId: state.pathParameters['farmId']!,
          cropId: state.pathParameters['cropId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.farmPlotNew,
        builder: (context, state) => PlotFormScreen(
          cropId: state.pathParameters['cropId']!,
          useSupabase: true,
          farmId: state.pathParameters['farmId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.farmPlotEdit,
        builder: (context, state) => PlotFormScreen(
          cropId: state.pathParameters['cropId']!,
          useSupabase: true,
          farmId: state.pathParameters['farmId']!,
          plot: state.extra as FarmPlot?,
        ),
      ),
      GoRoute(
        path: AppRoutes.farmPlotDetail,
        builder: (context, state) => FarmPlotDetailScreen(
          farmId: state.pathParameters['farmId']!,
          cropId: state.pathParameters['cropId']!,
          plotId: state.pathParameters['plotId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.farmDetail,
        builder: (context, state) =>
            FarmDetailScreen(farmId: state.pathParameters['farmId']!),
      ),
      // IMPORTANTE: cropNew va ANTES de cropDetail
      GoRoute(
        path: AppRoutes.crops,
        redirect: (context, state) => AppRoutes.farms,
      ),
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
        path: AppRoutes.plotOverview,
        builder: (context, state) => const PlotsOverviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.plotAlerts,
        builder: (context, state) =>
            const PlotsOverviewScreen(filter: PlotsOverviewFilter.alert),
      ),
      GoRoute(
        path: AppRoutes.plotDanger,
        builder: (context, state) =>
            const PlotsOverviewScreen(filter: PlotsOverviewFilter.danger),
      ),
      GoRoute(
        path: AppRoutes.careList,
        builder: (context, state) =>
            CareListScreen(plotId: state.pathParameters['plotId']!),
      ),
      GoRoute(
        path: AppRoutes.careNew,
        builder: (context, state) =>
            CareFormScreen(plotId: state.pathParameters['plotId']!),
      ),
      GoRoute(
        path: AppRoutes.careEdit,
        builder: (context, state) => CareFormScreen(
          plotId: state.pathParameters['plotId']!,
          initial: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: AppRoutes.careDetail,
        builder: (context, state) => CareDetailScreen(
          plotId: state.pathParameters['plotId']!,
          activityId: state.pathParameters['activityId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.plotStats,
        builder: (context, state) =>
            PlotStatsScreen(plotId: state.pathParameters['plotId']!),
      ),
      GoRoute(
        path: AppRoutes.plotTimeline,
        builder: (context, state) =>
            PlotTimelineScreen(plotId: state.pathParameters['plotId']!),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, state) => ReportsListScreen(
          plotId: state.pathParameters['plotId']!,
          initialReportId: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoutes.reportNew,
        builder: (context, state) =>
            ReportSetupScreen(plotId: state.pathParameters['plotId']!),
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
