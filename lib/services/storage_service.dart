import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload an evidence image/document for cyber complaints
  Future<String> uploadEvidenceFile(String localFilePath) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User must be logged in to upload files.");
    }

    try {
      final File file = File(localFilePath);
      if (!await file.exists()) {
        throw Exception("Source file does not exist: $localFilePath");
      }

      final String extension = p.extension(localFilePath);
      final String fileName = "${DateTime.now().millisecondsSinceEpoch}$extension";
      final String remotePath = "evidence/users/${user.uid}/complaints/$fileName";

      final Reference ref = _storage.ref().child(remotePath);
      final UploadTask task = ref.putFile(file);

      final TaskSnapshot snapshot = await task;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print("☁️ Evidence file uploaded successfully to Firebase Storage. URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("❌ Firebase Storage upload error: $e");
      rethrow;
    }
  }

  // Upload an SOS background voice recording
  Future<String> uploadVoiceRecord(String localFilePath) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User must be logged in to upload voice files.");
    }

    try {
      final File file = File(localFilePath);
      if (!await file.exists()) {
        throw Exception("Voice recording file does not exist: $localFilePath");
      }

      final String remotePath = "audio/users/${user.uid}/sos/${DateTime.now().millisecondsSinceEpoch}.m4a";

      final Reference ref = _storage.ref().child(remotePath);
      final UploadTask task = ref.putFile(file);

      final TaskSnapshot snapshot = await task;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print("☁️ SOS Voice recording uploaded successfully to Firebase Storage. URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("❌ Firebase Storage voice upload error: $e");
      rethrow;
    }
  }
}
