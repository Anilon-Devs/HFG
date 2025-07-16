import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/campaigns/presentation/pages/campaigns_page.dart';
import '../../features/campaigns/presentation/pages/campaign_detail_page.dart';
import '../../features/campaigns/presentation/pages/create_campaign_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/verification_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/donations/presentation/pages/donation_page.dart';
import '../../shared/presentation/pages/splash_page.dart';
import '../../shared/presentation/widgets/main_layout.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authController = Get.find<AuthController>();
      final isAuthenticated = authController.isAuthenticated;
      final isLoading = authController.isLoading;
      
      // Debug print to understand the flow
      print('Router redirect: path=${state.uri.path}, loading=$isLoading, authenticated=$isAuthenticated');
      
      // Allow navigation between auth pages (login, register, forgot-password)
      final authPages = ['/login', '/register', '/forgot-password'];
      if (authPages.contains(state.uri.path)) {
        // If authenticated user tries to access auth pages, redirect to home
        if (isAuthenticated) {
          return '/home';
        }
        // Otherwise, allow access to auth pages
        return null;
      }
      
      // Show splash while loading (but not if already on splash)
      if (isLoading && state.uri.path != '/splash') {
        return '/splash';
      }
      
      // Protected routes
      final protectedRoutes = [
        '/home',
        '/campaigns',
        '/profile',
        '/verification',
        '/create-campaign',
        '/admin',
        '/donate',
      ];
      
      // If user is not authenticated and trying to access protected route
      if (!isAuthenticated && protectedRoutes.any((route) => state.uri.path.startsWith(route))) {
        return '/login';
      }
      
      // If on splash and not loading
      if (state.uri.path == '/splash' && !isLoading) {
        return isAuthenticated ? '/home' : '/login';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/campaigns',
            builder: (context, state) => const CampaignsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/verification',
            builder: (context, state) => const VerificationPage(),
          ),
          GoRoute(
            path: '/create-campaign',
            builder: (context, state) => const CreateCampaignPage(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/campaign/:id',
        builder: (context, state) {
          final campaignId = state.pathParameters['id']!;
          return CampaignDetailPage(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: '/donate/:campaignId',
        builder: (context, state) {
          final campaignId = state.pathParameters['campaignId']!;
          return DonationPage(campaignId: campaignId);
        },
      ),
    ],
  );
}
