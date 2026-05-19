import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current logged in user
  User? get currentUser => _auth.currentUser;

  // 1. Phone OTP Verification
  Future<void> verifyPhone({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      String formattedPhone = phone;
      if (!phone.startsWith('+')) {
        formattedPhone = '+91$phone';
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("❌ Phone verification failed: ${e.message}");
          onError(e.message ?? "Phone verification failed. Please try again.");
        },
        codeSent: (String verificationId, int? resendToken) {
          print("📩 OTP Code sent to $formattedPhone. Verification ID: $verificationId");
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("⏳ OTP Code Auto Retrieval Timeout.");
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print("❌ Error verifying phone: $e");
      onError(e.toString());
    }
  }

  // Verify OTP Code and Sign In
  Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("🔑 User signed in successfully via Phone OTP: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      print("❌ Invalid OTP verification: $e");
      rethrow;
    }
  }

  // 2. Email & Password Authentication
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("🔑 User signed in successfully via Email: ${userCredential.user?.uid}");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("❌ Email sign-in failed: ${e.code} - ${e.message}");
      rethrow;
    }
  }

  // Register with Email & Password
  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("🔑 User registered successfully via Email: ${userCredential.user?.uid}");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("❌ Email registration failed: ${e.code} - ${e.message}");
      rethrow;
    }
  }

  // 3. Google Sign-In Authentication
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In interactive prompt
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        print("⚠️ Google Sign-In aborted by user.");
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("🔑 User signed in successfully via Google: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      print("❌ Google Sign-In failed: $e");
      rethrow;
    }
  }

  // Sign Out Session
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
    print("👤 User successfully signed out from all active sessions.");
  }
}
