import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../model/user_model.dart';
import '../services/analytics_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _verificationId;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get verificationId => _verificationId;

  // Constructor: Auto-listen to auth state changes and populate current user
  AuthController() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await loadUserFromFirestore(user);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Load User Profile from Firestore or create one
  Future<void> loadUserFromFirestore(User user) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
      } else {
        // Create new user profile if it doesn't exist yet (useful for Google/OTP fallback)
        _currentUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Priya Sharma',
          email: user.email ?? 'priya.sharma@example.com',
          phone: user.phoneNumber ?? '',
          profileImage: user.photoURL ?? '',
          trustedContacts: [
            {'name': 'Mother', 'phone': '+919876543211', 'relation': 'Mother'},
            {'name': 'Sister', 'phone': '+919876543212', 'relation': 'Sister'},
          ],
        );
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(_currentUser!.toMap());
      }
      notifyListeners();
    } catch (e) {
      print("❌ Error loading user profile from Firestore: $e");
    }
  }

  // 1. Phone OTP - Step 1: Send OTP
  Future<void> sendOtp(
    String phone, {
    required Function() onCodeSent,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _authService.verifyPhone(
      phone: phone,
      onCodeSent: (verId) {
        _verificationId = verId;
        _isLoading = false;
        notifyListeners();
        onCodeSent();
      },
      onError: (err) {
        _isLoading = false;
        notifyListeners();
        onError(err);
      },
    );
  }

  // Phone OTP - Step 2: Verify OTP
  Future<bool> loginWithOtp(String otpCode) async {
    if (_verificationId == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.verifyOtp(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );
      if (credential != null) {
        AnalyticsService.logLogin('Phone OTP');
      }
      _isLoading = false;
      notifyListeners();
      return credential != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 2. Email Login
  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmail(email, password);
      if (credential != null) {
        AnalyticsService.logLogin('Email');
      }
      _isLoading = false;
      notifyListeners();
      return credential != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Email Register / Sign Up
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.registerWithEmail(email, password);
      if (credential != null && credential.user != null) {
        final User user = credential.user!;
        
        // Write the custom details to Firestore before listener loads default values
        _currentUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          phone: phone,
          profileImage: '',
          trustedContacts: [
            {'name': 'Mother', 'phone': '+919876543211', 'relation': 'Mother'},
            {'name': 'Sister', 'phone': '+919876543212', 'relation': 'Sister'},
          ],
        );
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(_currentUser!.toMap());
        
        // Update user display name in FirebaseAuth
        await user.updateDisplayName(name);

        AnalyticsService.logSignUp('Email');
      }
      _isLoading = false;
      notifyListeners();
      return credential != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Google Sign-In
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null) {
        AnalyticsService.logLogin('Google');
      }
      _isLoading = false;
      notifyListeners();
      return credential != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout session
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}