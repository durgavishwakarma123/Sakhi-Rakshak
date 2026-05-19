class ApiConstants {
  // Base configuration
  static const String baseUrl = "https://api.smartsakhi.org/v1";

  // Authentication endpoints
  static const String login = "$baseUrl/auth/login";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String checkSession = "$baseUrl/auth/check-session";

  // Profile management endpoints
  static const String getProfile = "$baseUrl/user/profile";
  static const String updateProfile = "$baseUrl/user/profile/update";
  static const String uploadAvatar = "$baseUrl/user/profile/avatar";

  // Emergency contacts endpoints
  static const String getContacts = "$baseUrl/user/contacts";
  static const String addContact = "$baseUrl/user/contacts/add";
  static const String deleteContact = "$baseUrl/user/contacts/delete";

  // Cyber complaint endpoints
  static const String fileComplaint = "$baseUrl/complaints/file";
  static const String getComplaints = "$baseUrl/complaints/history";

  // SOS security endpoints
  static const String dispatchSos = "$baseUrl/sos/dispatch";
  static const String updateSafetySettings = "$baseUrl/user/settings/safety";
  static const String updateMedicalDetails = "$baseUrl/user/settings/medical";
}
