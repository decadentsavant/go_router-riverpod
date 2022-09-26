import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  const User({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;
}

class UserState extends StateNotifier<User?> {
  UserState() : super(null);
  String? myToken;

  Future<void> login(String email, String password) async {
    // This mocks a login attempt with email and password
    state = await Future.delayed(
      const Duration(milliseconds: 750),
      () => const User(name: 'My Name', email: "My Email"),
    );
    myToken = 'my_super_secre_token'; // Mock of permanent storage save
  }

  Future<void> loginWithToken() async {
    if (myToken == null) throw const LogoutException('Nothing to do here');

    // This mocks a login attempt with a saved token
    final loginAttempt = await Future.delayed(
      const Duration(milliseconds: 750),
      () => Random().nextBool(),
    );

    // If the attempt suceeds, the current page can be shown
    if (loginAttempt) state = const User(name: 'My Name', email: 'My Email');

    // If the attempt fails, returns 401, or whatever, redirect to login
    throw const UnauthorizedException('Unauthorized');
  }

  Future<void> logout() async {
    // In this example user==null if we're logged out
    myToken = null; // Remove the token from our perma storage FIRST(!!)
    state = null; // No request is mocked here, but could
  }
}

final userProvider = StateNotifierProvider<UserState, User?>((ref) {
  return UserState();
});

class LogoutException implements Exception {
  const LogoutException(this.message);
  final String message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException(this.message);
  final String message;
}