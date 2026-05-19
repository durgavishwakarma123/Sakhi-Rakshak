import 'package:flutter/widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  // Private constructor
  AnalyticsService._();

  // Expose observer for navigator tracking safely (falls back to basic dummy in tests/uninitialized states)
  static NavigatorObserver get observer {
    try {
      return FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
    } catch (e) {
      print("⚠️ [Analytics] Firebase Analytics is not initialized, using fallback dummy observer.");
      return NavigatorObserver();
    }
  }
 
  // Expose raw instance safely
  static FirebaseAnalytics? get instance {
    try {
      return FirebaseAnalytics.instance;
    } catch (e) {
      print("⚠️ [Analytics] Firebase Analytics instance not accessible: $e");
      return null;
    }
  }

  // 1. Log Screen Views
  static Future<void> logScreenView(String screenName) async {
    try {
      final inst = instance;
      if (inst != null) {
        await inst.logScreenView(
          screenName: screenName,
          screenClass: screenName,
        );
        print("📊 [Analytics] Logged Screen View: $screenName");
      }
    } catch (e) {
      print("⚠️ [Analytics] Error logging screen view: $e");
    }
  }

  // 2. Log Sign In / Login Actions
  static Future<void> logLogin(String method) async {
    try {
      final inst = instance;
      if (inst != null) {
        await inst.logLogin(loginMethod: method);
        print("📊 [Analytics] Logged Login: $method");
      }
    } catch (e) {
      print("⚠️ [Analytics] Error logging login: $e");
    }
  }

  // 3. Log Registration / Sign Up Actions
  static Future<void> logSignUp(String method) async {
    try {
      final inst = instance;
      if (inst != null) {
        await inst.logSignUp(signUpMethod: method);
        print("📊 [Analytics] Logged Sign Up: $method");
      }
    } catch (e) {
      print("⚠️ [Analytics] Error logging sign up: $e");
    }
  }

  // 4. Log SOS Emergency Alert Triggers
  static Future<void> logSosTriggered(double lat, double lng) async {
    try {
      final inst = instance;
      if (inst != null) {
        await inst.logEvent(
          name: 'sos_alert_triggered',
          parameters: {
            'latitude': lat,
            'longitude': lng,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        print("📊 [Analytics] Logged SOS Triggered: ($lat, $lng)");
      }
    } catch (e) {
      print("⚠️ [Analytics] Error logging SOS trigger: $e");
    }
  }

  // 5. Log SOS Emergency Alert Cancellations
  static Future<void> logSosStopped() async {
    try {
      final inst = instance;
      if (inst != null) {
        await inst.logEvent(
          name: 'sos_alert_stopped',
          parameters: {
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        print("📊 [Analytics] Logged SOS Stopped.");
      }
    } catch (e) {
      print("⚠️ [Analytics] Error logging SOS stop: $e");
    }
  }

  // 6. Log Incident Report Filing
  static Future<void> logComplaintFiled(String category, int evidenceCount) async {
    try {
      final inst = instance;
      if (inst != null) {
        await inst.logEvent(
          name: 'incident_complaint_filed',
          parameters: {
            'category': category,
            'evidence_count': evidenceCount,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        print("📊 [Analytics] Logged Incident Filed: category=$category, evidence=$evidenceCount");
      }
    } catch (e) {
      print("⚠️ [Analytics] Error logging complaint filing: $e");
    }
  }

  // 7. Log Profile Configuration updates
  static Future<void> logProfileUpdated() async {
    try {
      final inst = instance;
      if (inst != null) {
        await inst.logEvent(name: 'user_profile_updated');
        print("📊 [Analytics] Logged profile updates.");
      }
    } catch (e) {
      print("⚠️ [Analytics] Error logging profile update: $e");
    }
  }
}
