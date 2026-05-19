import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../services/sms_service.dart';
import '../services/audio_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

class SosController extends ChangeNotifier {
  final SmsService _smsService = SmsService();
  final AudioService _audioService = AudioService();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  bool _isSOSActive = false;
  bool get isSOSActive => _isSOSActive;

  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<Position>? _positionStreamSubscription;

  SosController() {
    startListeningToShake();
  }

  void startListeningToShake() {
    try {
      const double shakeThreshold = 18.0; // Acceleration threshold (m/s^2) to detect shake
      
      _accelerometerSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
        double gX = event.x;
        double gY = event.y;
        double gZ = event.z;
        
        double acceleration = sqrt(gX * gX + gY * gY + gZ * gZ);
        if (acceleration > shakeThreshold) {
          if (!_isSOSActive) {
            triggerSOS();
          }
        }
      });
      print("🚨 Shake detector active and monitoring accelerometer movements.");
    } catch (e) {
      print("❌ Failed to initialize Custom Shake detector: $e");
    }
  }

  void stopListeningToShake() {
    _accelerometerSubscription?.cancel();
  }

  // Step 1: Trigger active emergency panic alert
  Future<void> triggerSOS() async {
    _isSOSActive = true;
    notifyListeners();

    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? 'anonymous_user';
    final String phone = user?.phoneNumber ?? '+919876543210';

    try {
      // 1. Get initial location and compile dynamic tracking map link
      final loc = await _locationService.getCurrentLocation();
      
      // Log event to Firebase Analytics
      AnalyticsService.logSosTriggered(loc.latitude, loc.longitude);

      final mapLink = "https://maps.google.com/?q=${loc.latitude},${loc.longitude}";
      final message = "🚨 EMERGENCY ALERT from Sakhi Rakshak! I am in critical danger. Track me real-time: $mapLink";
      
      // 2. Start background mic recording
      await _audioService.startRecording();
      
      // 3. Dispatch automated SMS alerts to trusted circle
      // Load contacts from SharedPreferences/Firestore or fallback default
      List<String> recipients = ['+919876543211']; // Papa fallback
      try {
        final profileDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (profileDoc.exists) {
          final List<dynamic> contacts = profileDoc.data()?['contacts'] ?? [];
          if (contacts.isNotEmpty) {
            recipients = contacts.map((c) => c['phone'] as String).toList();
          }
        }
      } catch (e) {
        print("⚠️ Failed to load user custom contacts. Using default Papa recipient: $e");
      }

      // 3. Dispatch SOS alerts via SMS + WhatsApp to trusted circle
      await _smsService.sendSOSAlerts(recipients, message);

      // 4. Initialize Firebase Realtime Database session for sub-second emergency tracking
      await FirebaseDatabase.instance.ref('sos_active_sessions/$uid').set({
        'active': true,
        'uid': uid,
        'phone': phone,
        'userName': user?.displayName ?? 'Priyanka Sen',
        'latitude': loc.latitude,
        'longitude': loc.longitude,
        'startedAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });

      // 5. Start live location streaming subscription
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 3, // Push database updates every 3 meters of movement
        ),
      ).listen((Position position) {
        FirebaseDatabase.instance.ref('sos_active_sessions/$uid').update({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'updatedAt': ServerValue.timestamp,
        });
        print("📍 Real-time GPS coordinate stream update pushed: (${position.latitude}, ${position.longitude})");
      });

      print("🔥 Real-time SOS Dispatch successfully fully broadcasted!");
    } catch (e) {
      print("❌ Error triggering SOS: $e");
    }
  }

  // Step 2: Stop panic alert, upload captures, and log details
  Future<void> stopSOS() async {
    _isSOSActive = false;
    notifyListeners();

    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? 'anonymous_user';

    try {
      // Log event to Firebase Analytics
      AnalyticsService.logSosStopped();

      // 1. Cancel live GPS streaming
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      // 2. Terminate session inside Realtime Database
      await FirebaseDatabase.instance.ref('sos_active_sessions/$uid').update({
        'active': false,
        'stoppedAt': ServerValue.timestamp,
      });

      // 3. Stop recording audio and grab local file pointer
      final String? localAudioPath = await _audioService.stopRecording();
      String? remoteAudioUrl;

      if (localAudioPath != null && localAudioPath.isNotEmpty) {
        try {
          // 4. Securely upload file evidence directly to Firebase Storage
          remoteAudioUrl = await _storageService.uploadVoiceRecord(localAudioPath);
        } catch (e) {
          print("⚠️ Evidence audio upload failed: $e");
        }
      }

      // 5. Save the finished incident detail log under Firestore history collection
      await FirebaseFirestore.instance.collection('sos_history').add({
        'userId': uid,
        'phone': user?.phoneNumber ?? '+919876543210',
        'userName': user?.displayName ?? 'Priyanka Sen',
        'timestamp': FieldValue.serverTimestamp(),
        'audioUrl': remoteAudioUrl ?? '',
        'status': 'Resolved',
      });

      print("✅ SOS emergency session deactivated, logged, and secured.");
    } catch (e) {
      print("❌ Error stopping SOS: $e");
    }
  }

  @override
  void dispose() {
    stopListeningToShake();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}