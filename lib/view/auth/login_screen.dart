import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../home/main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Tab selector: 0 for Phone OTP, 1 for Email Login
  int _activeTab = 0;

  // Controllers for Phone OTP
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;

  // Controllers for Email Login / Register
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  bool _isEmailSignUp = false; // Toggles between login and registration forms

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _regPhoneController.dispose();
    super.dispose();
  }

  // --- 1. Phone OTP Verification Trigger ---
  void _handleSendOtp() {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please enter your mobile number."), backgroundColor: Colors.orangeAccent),
      );
      return;
    }
    
    final authController = Provider.of<AuthController>(context, listen: false);
    authController.sendOtp(
      _phoneController.text.trim(),
      onCodeSent: () {
        setState(() {
          _isOtpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("📩 Verification OTP sent successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: (errorMsg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ $errorMsg"),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
    );
  }

  void _handleVerifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please enter a valid 6-digit OTP code."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.loginWithOtp(_otpController.text.trim());

    _finalizeLoginSession(success, "Logged in successfully via Phone OTP!");
  }

  // --- 2. Email Login / Registration Triggers ---
  void _handleEmailAccess() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    bool success = false;

    if (_isEmailSignUp) {
      success = await authController.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _regPhoneController.text.trim(),
      );
      _finalizeLoginSession(success, "Account registered and logged in successfully!");
    } else {
      success = await authController.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      _finalizeLoginSession(success, "Logged in successfully via Email!");
    }
  }

  // --- 3. Google Sign-In Trigger ---
  void _handleGoogleAccess() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.loginWithGoogle();
    _finalizeLoginSession(success, "Logged in successfully via Google!");
  }

  // Finalize Session Redirection
  void _finalizeLoginSession(bool success, String successMessage) async {
    if (success) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
      } catch (e) {
        print("Failed to save login session: $e");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ $successMessage"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Authentication failed. Please check credentials and try again."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      "Sakhi Rakshak Shield",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      "Empowering safety, security, and digital peace.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dynamic Custom Navigation Tab Selector
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeTab = 0;
                                _formKey.currentState?.reset();
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _activeTab == 0 ? AppColors.secondary : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                "Mobile OTP",
                                style: TextStyle(
                                  color: _activeTab == 0 ? Colors.black : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeTab = 1;
                                _formKey.currentState?.reset();
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _activeTab == 1 ? AppColors.secondary : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                "Email Portal",
                                style: TextStyle(
                                  color: _activeTab == 1 ? Colors.black : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Content Panel toggles between tabs
                  _activeTab == 0 ? _buildPhoneLoginView(authController) : _buildEmailLoginView(authController),

                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("OR CONTINUE WITH", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Premium Google Sign-In Action Button
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white24, width: 1.5),
                        color: Colors.white.withOpacity(0.04),
                      ),
                      child: InkWell(
                        onTap: _handleGoogleAccess,
                        borderRadius: BorderRadius.circular(28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                              height: 20,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.blueAccent, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Sign in with Google",
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Phone OTP Layout Block ---
  Widget _buildPhoneLoginView(AuthController controller) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: !_isOtpSent ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Column(
        children: [
          CustomTextField(
            controller: _phoneController,
            label: "Mobile Number",
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: "SEND VERIFICATION OTP",
            isLoading: controller.isLoading,
            color: AppColors.secondary,
            onPressed: _handleSendOtp,
          ),
        ],
      ),
      secondChild: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Verifying +91 ${_phoneController.text}",
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isOtpSent = false;
                    _otpController.clear();
                  });
                },
                child: const Text(
                  "Change",
                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _otpController,
            label: "6-Digit Secure OTP",
            prefixIcon: Icons.security,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: "CONFIRM & LOG IN",
            isLoading: controller.isLoading,
            color: AppColors.secondary,
            onPressed: _handleVerifyOtp,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _handleSendOtp,
            child: const Text(
              "Resend OTP Code",
              style: TextStyle(color: Colors.white60, fontSize: 13, decoration: TextDecoration.underline),
            ),
          )
        ],
      ),
    );
  }

  // --- Email Login / Registration Panel Block ---
  Widget _buildEmailLoginView(AuthController controller) {
    return Column(
      children: [
        // Fields displayed only during Email Account Creation
        if (_isEmailSignUp) ...[
          CustomTextField(
            controller: _nameController,
            label: "Full Name",
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            validator: (val) => val == null || val.trim().isEmpty ? "Please enter your name" : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _regPhoneController,
            label: "Contact Mobile Number",
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            validator: AppValidators.validatePhone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),
        ],

        CustomTextField(
          controller: _emailController,
          label: "Email Address",
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          validator: AppValidators.validateEmail,
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: _passwordController,
          label: "Password",
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          validator: (val) => val == null || val.length < 6 ? "Password must be at least 6 characters" : null,
        ),
        const SizedBox(height: 24),

        CustomButton(
          text: _isEmailSignUp ? "REGISTER NEW ACCOUNT" : "SIGN IN VIA EMAIL",
          isLoading: controller.isLoading,
          color: AppColors.secondary,
          onPressed: _handleEmailAccess,
        ),
        const SizedBox(height: 12),

        // Toggle link to slide between sign-in and register modes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isEmailSignUp ? "Already have an account?" : "Need a safety shield profile?",
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isEmailSignUp = !_isEmailSignUp;
                  _formKey.currentState?.reset();
                });
              },
              child: Text(
                _isEmailSignUp ? "Login here" : "Sign up here",
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            )
          ],
        )
      ],
    );
  }
}