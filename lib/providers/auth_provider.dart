import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, unauthenticated, authenticated }

/// Read narrow fields with `context.select<AuthProvider, AppUser?>((p) => p.currentUser)`
/// or `Selector<AuthProvider, AuthStatus>` so the whole tree does not rebuild.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  AuthStatus _status = AuthStatus.initial;
  AppUser? _currentUser;
  String? _error;
  bool _isLoading = false;
  bool _disposed = false;

  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  UserRole? get role => _currentUser?.role;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get needsRoleSelection => isAuthenticated && _currentUser?.role == null;

  void initialize() {
    _authSubscription?.cancel();
    _authSubscription = _authService.authStateChanges.listen(_handleAuthUser);
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _runGuarded(() async {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _runGuarded(() async {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> signInWithGoogle() {
    return _runGuarded(() async {
      await _authService.signInWithGoogle();
    });
  }

  Future<void> signOut() {
    return _runGuarded(_authService.signOut);
  }

  Future<void> selectRole(UserRole role) async {
    final User? firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      _error = 'Please sign in before choosing a role.';
      _notify();
      return;
    }

    _isLoading = true;
    _error = null;
    _notify();

    try {
      await _authService.updateUserRole(firebaseUser.uid, role);
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(role: role);
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> switchRole(UserRole role) => selectRole(role);

  void clearError() {
    if (_error == null) return;
    _error = null;
    _notify();
  }

  Future<void> _handleAuthUser(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _error = null;
      _notify();
      return;
    }

    try {
      _currentUser = await _authService.readUser(firebaseUser.uid);
      _currentUser ??= await _authService.ensureUserDoc(user: firebaseUser);
      _status = AuthStatus.authenticated;
    } catch (error) {
      _currentUser = null;
      _status = AuthStatus.authenticated;
      _error = error.toString();
    }
    _notify();
  }

  Future<void> _runGuarded(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    _notify();
    try {
      await action();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }
}
