import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/stories/data/story_repository.dart';
import '../../features/stories/presentation/pages/story_list_page.dart';
import '../../features/stories/presentation/pages/story_detail_page.dart';
import '../../features/stories/presentation/pages/add_story_page.dart';
import '../../features/stories/presentation/pages/location_picker_page.dart';
import '../../features/stories/presentation/providers/story_list_provider.dart';
import '../network/api_service.dart';

/// Route path constants — single source of truth for all navigation.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String stories = '/stories';
  static const String storyDetail = '/stories/:id';
  static const String addStory = '/stories/add';
  static const String locationPicker = '/stories/add/location';
}

/// Builds the [GoRouter] that drives the entire app.
///
/// The redirect logic reads [AuthProvider.isLoggedIn]:
/// - Unauthenticated → /login
/// - Authenticated + on auth route → /stories
///
/// The router refreshes automatically whenever [AuthProvider] notifies.
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.stories,
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final onAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isLoggedIn && !onAuthRoute) return AppRoutes.login;
      if (isLoggedIn && onAuthRoute) return AppRoutes.stories;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.stories,
        builder: (context, state) {
          // Inject StoryListProvider scoped to the stories route.
          // It reads token from AuthProvider above in the widget tree.
          final auth = context.read<AuthProvider>();
          final api = context.read<ApiService>();
          return ChangeNotifierProvider(
            create: (_) => StoryListProvider(
              repository: StoryRepository(api),
              token: auth.token ?? '',
            ),
            child: const StoryListPage(),
          );
        },
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddStoryPage(),
            routes: [
              GoRoute(
                path: 'location',
                builder: (context, state) => const LocationPickerPage(),
              ),
            ],
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return StoryDetailPage(storyId: id);
            },
          ),
        ],
      ),
    ],
  );
}
