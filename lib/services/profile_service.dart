import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  // Persistence Keys
  static const String keyName = 'profile_name';
  static const String keyPhone = 'profile_phone';
  static const String keyEmail = 'profile_email';
  static const String keyDob = 'profile_dob';
  static const String keyGender = 'profile_gender';
  static const String keyAddress = 'profile_address';
  static const String keyCity = 'profile_city';
  static const String keyState = 'profile_state';
  static const String keyImagePath = 'profile_image_path';
  static const String keyContacts = 'profile_contacts';

  static const String keyShakeSos = 'setting_shake_sos';
  static const String keyVoiceSos = 'setting_voice_sos';
  static const String keyAutoRecord = 'setting_auto_record';
  static const String keyLiveTracking = 'setting_live_tracking';

  static const String keyBloodGroup = 'medical_blood';
  static const String keyConditions = 'medical_conditions';
  static const String keyAllergies = 'medical_allergies';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load complete profile preferences (syncing with Cloud Firestore if online)
  Future<Map<String, dynamic>> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        final doc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          print("📦 Profile fetched from Firestore for user: ${currentUser.uid}");

          // Cache everything locally in SharedPreferences for offline access
          await prefs.setString(keyName, data['name'] ?? 'Priya Sharma');
          await prefs.setString(keyPhone, data['phone'] ?? currentUser.phoneNumber ?? '');
          await prefs.setString(keyEmail, data['email'] ?? 'priya.sharma@example.com');
          await prefs.setString(keyDob, data['dob'] ?? '15/08/1998');
          await prefs.setString(keyGender, data['gender'] ?? 'Female');
          await prefs.setString(keyAddress, data['address'] ?? '123, Saket Marg');
          await prefs.setString(keyCity, data['city'] ?? 'New Delhi');
          await prefs.setString(keyState, data['state'] ?? 'Delhi');
          await prefs.setString(keyImagePath, data['imagePath'] ?? '');
          await prefs.setBool(keyShakeSos, data['shakeSos'] ?? true);
          await prefs.setBool(keyVoiceSos, data['voiceSos'] ?? true);
          await prefs.setBool(keyAutoRecord, data['autoRecord'] ?? true);
          await prefs.setBool(keyLiveTracking, data['liveTracking'] ?? true);
          await prefs.setString(keyBloodGroup, data['bloodGroup'] ?? 'O+');
          await prefs.setString(keyConditions, data['conditions'] ?? 'None');
          await prefs.setString(keyAllergies, data['allergies'] ?? 'Dust, Penicillin');

          final List<dynamic> contactsRaw = data['contacts'] ?? [];
          final List<Map<String, String>> contacts = contactsRaw
              .map((item) => Map<String, String>.from(item as Map))
              .toList();
          await prefs.setString(keyContacts, jsonEncode(contacts));

          return {
            'name': data['name'] ?? 'Priya Sharma',
            'phone': data['phone'] ?? currentUser.phoneNumber ?? '',
            'email': data['email'] ?? 'priya.sharma@example.com',
            'dob': data['dob'] ?? '15/08/1998',
            'gender': data['gender'] ?? 'Female',
            'address': data['address'] ?? '123, Saket Marg',
            'city': data['city'] ?? 'New Delhi',
            'state': data['state'] ?? 'Delhi',
            'imagePath': data['imagePath'],
            'contacts': contacts,
            'shakeSos': data['shakeSos'] ?? true,
            'voiceSos': data['voiceSos'] ?? true,
            'autoRecord': data['autoRecord'] ?? true,
            'liveTracking': data['liveTracking'] ?? true,
            'bloodGroup': data['bloodGroup'] ?? 'O+',
            'conditions': data['conditions'] ?? 'None',
            'allergies': data['allergies'] ?? 'Dust, Penicillin',
          };
        }
      } catch (e) {
        print("⚠️ Failed to load from Firestore. Using offline local cache fallback: $e");
      }
    }

    // Offline or Fallback: Load from SharedPreferences
    final String? contactsJson = prefs.getString(keyContacts);
    List<Map<String, String>> contacts = [];
    if (contactsJson != null) {
      final List<dynamic> decodedList = jsonDecode(contactsJson);
      contacts = decodedList
          .map((item) => Map<String, String>.from(item as Map))
          .toList();
    } else {
      contacts = [
        {'name': 'Mother', 'phone': '+91 98765 43211', 'relation': 'Mother'},
        {'name': 'Sister', 'phone': '+91 98765 43212', 'relation': 'Sister'},
        {'name': 'Friend', 'phone': '+91 98765 43213', 'relation': 'Friend'},
      ];
    }

    return {
      'name': prefs.getString(keyName) ?? 'Priya Sharma',
      'phone': prefs.getString(keyPhone) ?? '+91 98765 43210',
      'email': prefs.getString(keyEmail) ?? 'priya.sharma@example.com',
      'dob': prefs.getString(keyDob) ?? '15/08/1998',
      'gender': prefs.getString(keyGender) ?? 'Female',
      'address': prefs.getString(keyAddress) ?? '123, Saket Marg',
      'city': prefs.getString(keyCity) ?? 'New Delhi',
      'state': prefs.getString(keyState) ?? 'Delhi',
      'imagePath': prefs.getString(keyImagePath),
      'contacts': contacts,
      'shakeSos': prefs.getBool(keyShakeSos) ?? true,
      'voiceSos': prefs.getBool(keyVoiceSos) ?? true,
      'autoRecord': prefs.getBool(keyAutoRecord) ?? true,
      'liveTracking': prefs.getBool(keyLiveTracking) ?? true,
      'bloodGroup': prefs.getString(keyBloodGroup) ?? 'O+',
      'conditions': prefs.getString(keyConditions) ?? 'None',
      'allergies': prefs.getString(keyAllergies) ?? 'Dust, Penicillin',
    };
  }

  // Save personal details
  Future<void> savePersonalData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyName, data['name'] ?? '');
    await prefs.setString(keyPhone, data['phone'] ?? '');
    await prefs.setString(keyEmail, data['email'] ?? '');
    await prefs.setString(keyDob, data['dob'] ?? '');
    await prefs.setString(keyGender, data['gender'] ?? '');
    await prefs.setString(keyAddress, data['address'] ?? '');
    await prefs.setString(keyCity, data['city'] ?? '');
    await prefs.setString(keyState, data['state'] ?? '');

    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'name': data['name'] ?? '',
          'phone': data['phone'] ?? '',
          'email': data['email'] ?? '',
          'dob': data['dob'] ?? '',
          'gender': data['gender'] ?? '',
          'address': data['address'] ?? '',
          'city': data['city'] ?? '',
          'state': data['state'] ?? '',
        }, SetOptions(merge: true));
        print("☁️ Personal data synchronized with Firestore.");
      } catch (e) {
        print("❌ Error uploading personal data: $e");
      }
    }
  }

  // Save medical details
  Future<void> saveMedicalData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyBloodGroup, data['bloodGroup'] ?? '');
    await prefs.setString(keyConditions, data['conditions'] ?? '');
    await prefs.setString(keyAllergies, data['allergies'] ?? '');

    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'bloodGroup': data['bloodGroup'] ?? '',
          'conditions': data['conditions'] ?? '',
          'allergies': data['allergies'] ?? '',
        }, SetOptions(merge: true));
        print("☁️ Medical details synchronized with Firestore.");
      } catch (e) {
        print("❌ Error uploading medical data: $e");
      }
    }
  }

  // Save safety toggle state
  Future<void> saveToggleState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        // Map preference key to firestore field
        String field = '';
        if (key == keyShakeSos) field = 'shakeSos';
        else if (key == keyVoiceSos) field = 'voiceSos';
        else if (key == keyAutoRecord) field = 'autoRecord';
        else if (key == keyLiveTracking) field = 'liveTracking';

        if (field.isNotEmpty) {
          await _firestore.collection('users').doc(currentUser.uid).update({
            field: value,
          });
          print("☁️ Safety toggle state ($field) synchronized with Firestore.");
        }
      } catch (e) {
        print("❌ Error updating toggle state in Firestore: $e");
      }
    }
  }

  // Save dynamic emergency contacts list
  Future<void> saveContactsList(List<Map<String, String>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(contacts);
    await prefs.setString(keyContacts, encoded);

    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'contacts': contacts,
        });
        print("☁️ Emergency contacts list synchronized with Firestore.");
      } catch (e) {
        print("❌ Error updating contacts list in Firestore: $e");
      }
    }
  }

  // Save avatar image path
  Future<void> saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyImagePath, path);

    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'imagePath': path,
        });
        print("☁️ Avatar path synchronized with Firestore.");
      } catch (e) {
        print("❌ Error updating avatar path in Firestore: $e");
      }
    }
  }
}
