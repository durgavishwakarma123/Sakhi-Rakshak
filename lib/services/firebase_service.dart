import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      print("✅ Firebase initialized successfully.");
      
      // Initialize Google Sign-In instance (Required for Google Sign-In v7+)
      await GoogleSignIn.instance.initialize();
      print("✅ Google Sign-In initialized successfully.");

      // Setup Firebase Crashlytics error loggers
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      print("✅ Firebase Crashlytics initialized successfully.");
    } catch (e) {
      print("❌ Core Services initialization error: $e");
    }
  }
}