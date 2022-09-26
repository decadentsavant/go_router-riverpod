import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_riverpod/user.dart';

import 'main.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = AsyncRouterNotifier(ref);

  return GoRouter(
    debugLogDiagnostics: true, // For testing, obviously
    refreshListenable: router, // Notifies 'GoRouter' about refresh events
    redirect: router._redirect, // All the logic is centralized here
    routes: router._routes, // All routes are found here
  );
});

// Allows for async redirects
class AsyncRouterNotifier extends ChangeNotifier {
  AsyncRouterNotifier(this._ref) {
    _ref.listen<User?>(
      userProvider,
      (previous, next) => notifyListeners(),
    );
  }
  final Ref _ref;

  Future<String?> _redirect(BuildContext context, GoRouterState state) async {
    final user = _ref.read(userProvider);

      // if not logged in...
    if (user == null) {
        // ...and we're on on the login page...
      if (state.location == '/login') {
        return null; // ...then no redirect is needed if we're inserting credentials
      }
      try {
        // Otherwise, we're not on the login page (only 2 pages in this example), and we're not logged in
        await _ref
            .read(userProvider.notifier)
            .loginWithToken(); // We might still have auth state so give it a shot
        return null; // ...if it succeeds we can show the other page since we're already there (again, only two pages)
      } on UnauthorizedException catch (err) {
        // The attempt failed...handle it somehow
        // ignore: avoid_print
        print(err);
        return '/login';
      } on LogoutException catch (_) {
        // No attempt was made: we got logged out and...
        return '/login'; // ...need to redirect to the login page.
      }
    }
    // We're logged in down here
    if (state.location == '/login') {
      return '/';
    } // So if we're still on the login page, go to home page
    return null;
  }

  List<GoRoute> get _routes => [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (content, _) => const HomePage(),
        ),
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, _) => const LoginPage(),
        ),
      ];
}
