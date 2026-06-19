// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/enums.dart';

class AuthController extends ChangeNotifier {
  // In-memory user store (simulates a backend)
  final Map<String, Map<String, String>> _registeredUsers = {};

  UserModel? _currentUser;
  AuthState _state = AuthState.idle;
  String? _errorMessage;
  bool _rememberMe = false;

  UserModel? get currentUser => _currentUser;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get isLoggedIn => _currentUser != null;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<void> checkRememberedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getBool('rememberMe') ?? false;
    if (remembered) {
      final email = prefs.getString('userEmail') ?? '';
      final fullName = prefs.getString('userName') ?? '';
      final genderName = prefs.getString('userGender') ?? Gender.preferNotToSay.name;
      if (email.isNotEmpty) {
        _currentUser = UserModel(
          fullName: fullName,
          email: email,
          gender: Gender.values.firstWhere(
            (g) => g.name == genderName,
            orElse: () => Gender.preferNotToSay,
          ),
        );
        notifyListeners();
      }
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required Gender gender,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // simulate network

    if (_registeredUsers.containsKey(email.toLowerCase())) {
      _state = AuthState.error;
      _errorMessage = 'An account with this email already exists.';
      notifyListeners();
      return false;
    }

    _registeredUsers[email.toLowerCase()] = {
      'fullName': fullName,
      'password': password,
      'gender': gender.name,
    };

    _state = AuthState.success;
    notifyListeners();
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900)); // simulate network

    final userData = _registeredUsers[email.toLowerCase()];
    if (userData == null) {
      _state = AuthState.error;
      _errorMessage = 'No account found with this email.';
      notifyListeners();
      return false;
    }

    if (userData['password'] != password) {
      _state = AuthState.error;
      _errorMessage = 'Incorrect password. Please try again.';
      notifyListeners();
      return false;
    }

    _currentUser = UserModel(
      fullName: userData['fullName']!,
      email: email,
      gender: Gender.values.firstWhere(
        (g) => g.name == userData['gender'],
        orElse: () => Gender.preferNotToSay,
      ),
    );

    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', _currentUser!.fullName);
      await prefs.setString('userGender', _currentUser!.gender.name);
    }

    _state = AuthState.success;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    _state = AuthState.idle;
    _rememberMe = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  void resetState() {
    _state = AuthState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
