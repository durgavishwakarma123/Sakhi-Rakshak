import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  // Personal parameters
  String _name = 'Priya Sharma';
  String _phone = '+91 98765 43210';
  String _email = 'priya.sharma@example.com';
  String _dob = '15/08/1998';
  String _gender = 'Female';
  String _address = '123, Saket Marg';
  String _city = 'New Delhi';
  String _state = 'Delhi';
  String? _avatarPath;

  // Medical parameters
  String _bloodGroup = 'O+';
  String _conditions = 'None';
  String _allergies = 'Dust, Penicillin';

  // Safety switches
  bool _shakeSos = true;
  bool _voiceSos = true;
  bool _autoRecord = true;
  bool _liveTracking = true;

  // Trusted contacts
  List<Map<String, String>> _contacts = [];

  bool _isLoading = true;

  // Getters
  String get name => _name;
  String get phone => _phone;
  String get email => _email;
  String get dob => _dob;
  String get gender => _gender;
  String get address => _address;
  String get city => _city;
  String get state => _state;
  String? get avatarPath => _avatarPath;

  String get bloodGroup => _bloodGroup;
  String get conditions => _conditions;
  String get allergies => _allergies;

  bool get shakeSos => _shakeSos;
  bool get voiceSos => _voiceSos;
  bool get autoRecord => _autoRecord;
  bool get liveTracking => _liveTracking;

  List<Map<String, String>> get contacts => _contacts;
  bool get isLoading => _isLoading;

  // Load persistent user settings
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _profileService.loadProfileData();
      _name = data['name'];
      _phone = data['phone'];
      _email = data['email'];
      _dob = data['dob'];
      _gender = data['gender'];
      _address = data['address'];
      _city = data['city'];
      _state = data['state'];
      _avatarPath = data['imagePath'];
      _contacts = data['contacts'];
      _shakeSos = data['shakeSos'];
      _voiceSos = data['voiceSos'];
      _autoRecord = data['autoRecord'];
      _liveTracking = data['liveTracking'];
      _bloodGroup = data['bloodGroup'];
      _conditions = data['conditions'];
      _allergies = data['allergies'];
    } catch (e) {
      print("Error loading profile settings: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update personal information
  Future<bool> savePersonalInfo({
    required String name,
    required String phone,
    required String email,
    required String dob,
    required String gender,
    required String address,
    required String city,
    required String state,
  }) async {
    try {
      _name = name;
      _phone = phone;
      _email = email;
      _dob = dob;
      _gender = gender;
      _address = address;
      _city = city;
      _state = state;

      await _profileService.savePersonalData({
        'name': name,
        'phone': phone,
        'email': email,
        'dob': dob,
        'gender': gender,
        'address': address,
        'city': city,
        'state': state,
      });
      notifyListeners();
      return true;
    } catch (e) {
      print("Failed to save personal data: $e");
      return false;
    }
  }

  // Update medical details
  Future<bool> saveMedicalDetails({
    required String bloodGroup,
    required String conditions,
    required String allergies,
  }) async {
    try {
      _bloodGroup = bloodGroup;
      _conditions = conditions;
      _allergies = allergies;

      await _profileService.saveMedicalData({
        'bloodGroup': bloodGroup,
        'conditions': conditions,
        'allergies': allergies,
      });
      notifyListeners();
      return true;
    } catch (e) {
      print("Failed to save medical details: $e");
      return false;
    }
  }

  // Toggle safety settings
  Future<void> setShakeSos(bool val) async {
    _shakeSos = val;
    notifyListeners();
    await _profileService.saveToggleState(ProfileService.keyShakeSos, val);
  }

  Future<void> setVoiceSos(bool val) async {
    _voiceSos = val;
    notifyListeners();
    await _profileService.saveToggleState(ProfileService.keyVoiceSos, val);
  }

  Future<void> setAutoRecord(bool val) async {
    _autoRecord = val;
    notifyListeners();
    await _profileService.saveToggleState(ProfileService.keyAutoRecord, val);
  }

  Future<void> setLiveTracking(bool val) async {
    _liveTracking = val;
    notifyListeners();
    await _profileService.saveToggleState(ProfileService.keyLiveTracking, val);
  }

  // Add trusted emergency contact
  Future<void> addEmergencyContact(String name, String phone, String relation) async {
    _contacts.add({
      'name': name,
      'phone': phone,
      'relation': relation,
    });
    notifyListeners();
    await _profileService.saveContactsList(_contacts);
  }

  // Remove trusted emergency contact
  Future<void> removeEmergencyContact(int index) async {
    if (index >= 0 && index < _contacts.length) {
      _contacts.removeAt(index);
      notifyListeners();
      await _profileService.saveContactsList(_contacts);
    }
  }

  // Update profile avatar image path
  Future<void> setAvatarPath(String path) async {
    _avatarPath = path;
    notifyListeners();
    await _profileService.saveAvatarPath(path);
  }
}
