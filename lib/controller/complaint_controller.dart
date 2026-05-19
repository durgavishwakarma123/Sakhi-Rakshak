import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/complaint_model.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

class ComplaintController extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<ComplaintModel> _complaintHistory = [];
  bool _isSubmitting = false;
  StreamSubscription? _complaintsSubscription;

  List<ComplaintModel> get complaintHistory => _complaintHistory;
  bool get isSubmitting => _isSubmitting;

  ComplaintController() {
    // Listen to Firebase Auth state changes to dynamically initialize Firestore listener
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      initComplaintSync();
    });
  }

  // Subscribe to real-time complaint updates for active user
  void initComplaintSync() {
    _complaintsSubscription?.cancel();
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _complaintHistory = [];
      notifyListeners();
      return;
    }

    try {
      _complaintsSubscription = FirebaseFirestore.instance
          .collection('complaints')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
        _complaintHistory = snapshot.docs
            .map((doc) => ComplaintModel.fromMap(doc.data()))
            .toList();
        
        // Sort newest first
        _complaintHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }, onError: (error) {
        print("❌ Error listening to complaints: $error");
      });
    } catch (e) {
      print("❌ Failed to initialize complaint subscription: $e");
    }
  }

  // File secure cyber complaint
  Future<bool> fileComplaint({
    required String type,
    required String description,
    required List<String> evidences,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final List<String> remoteEvidenceUrls = [];

      // Upload local evidence files to Firebase Storage first
      for (final String path in evidences) {
        if (path.isNotEmpty) {
          final String remoteUrl = await _storageService.uploadEvidenceFile(path);
          remoteEvidenceUrls.add(remoteUrl);
        }
      }

      final String complaintId = 'CYBER-${DateTime.now().millisecondsSinceEpoch}';

      final newComplaint = ComplaintModel(
        complaintId: complaintId,
        userId: user.uid,
        type: type,
        description: description,
        status: 'Pending Review',
        evidenceUrls: remoteEvidenceUrls,
        latitude: 28.6139, // Default/current fallback
        longitude: 77.2090, // Default/current fallback
        address: 'Near Cyber Police Cell, New Delhi',
        createdAt: DateTime.now(),
      );

      // Write to Cloud Firestore
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .set(newComplaint.toMap());

      // Log event to Firebase Analytics
      AnalyticsService.logComplaintFiled(type, evidences.length);

      print("☁️ Cyber complaint $complaintId written successfully to Cloud Firestore!");
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ Failed to file complaint: $e");
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _complaintsSubscription?.cancel();
    super.dispose();
  }
}