import 'package:go_router/go_router.dart';
import 'package:cropguard/navigation/app_routes.dart';
import 'package:cropguard/presentation/common/placeholder_screen.dart';
import 'package:cropguard/presentation/screens/splash/splash_screen.dart';
import 'package:cropguard/presentation/screens/auth/login_screen.dart';
import 'package:cropguard/presentation/screens/auth/register_screen.dart';
import 'package:cropguard/presentation/screens/home/home_screen.dart';
import 'package:cropguard/presentation/screens/shell/main_shell.dart';
import 'package:cropguard/presentation/screens/history/history_screen.dart';
import 'package:cropguard/presentation/screens/crops/crops_screen.dart';
import 'package:cropguard/presentation/screens/crops/crop_detail_screen.dart';
import 'package:cropguard/presentation/screens/recommendations/recommendations_screen.dart';
import 'package:cropguard/presentation/screens/profile/profile_screen.dart';
import 'package:cropguard/presentation/screens/history/diagnosis_detail_screen.dart';

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
        path: AppRoutes.diagnose,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Diagnosticar enfermedad'),
      ),
      GoRoute(
        path: AppRoutes.recommendations,
        builder: (context, state) => const RecommendationsScreen(),
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
