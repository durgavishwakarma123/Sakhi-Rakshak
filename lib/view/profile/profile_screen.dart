import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/profile_controller.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local controllers for input forms
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  final _bloodController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _allergiesController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load and populate controller data after the first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ProfileController>(context, listen: false);
      controller.loadProfile().then((_) {
        _nameController.text = controller.name;
        _phoneController.text = controller.phone;
        _emailController.text = controller.email;
        _dobController.text = controller.dob;
        _genderController.text = controller.gender;
        _addressController.text = controller.address;
        _cityController.text = controller.city;
        _stateController.text = controller.state;

        _bloodController.text = controller.bloodGroup;
        _conditionsController.text = controller.conditions;
        _allergiesController.text = controller.allergies;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _bloodController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  // Interactive gallery selection for custom profile photo
  Future<void> _changeAvatar(ProfileController controller) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (file != null) {
        await controller.setAvatarPath(file.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("📷 Profile picture updated successfully!")),
          );
        }
      }
    } catch (e) {
      print("Avatar upload error: $e");
    }
  }

  // Dialog window for adding new emergency contacts
  void _showAddContactDialog(ProfileController controller) {
    final nameField = TextEditingController();
    final phoneField = TextEditingController();
    final relationField = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          title: const Text("Add Emergency Contact", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: nameField, label: "Full Name", prefixIcon: Icons.person),
                const SizedBox(height: 16),
                CustomTextField(controller: relationField, label: "Relationship (e.g. Brother)", prefixIcon: Icons.favorite),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: phoneField,
                  label: "Phone Number",
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              onPressed: () {
                if (nameField.text.isNotEmpty && phoneField.text.isNotEmpty) {
                  controller.addEmergencyContact(
                    nameField.text.trim(),
                    phoneField.text.trim(),
                    relationField.text.trim().isEmpty ? 'Contact' : relationField.text.trim(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("👥 New emergency contact saved!")),
                  );
                }
              },
              child: const Text("ADD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();

    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Profile Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // PROFILE BANNER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: AppColors.border,
                        backgroundImage: controller.avatarPath != null
                            ? FileImage(File(controller.avatarPath!)) as ImageProvider
                            : null,
                        child: controller.avatarPath == null
                            ? const Icon(Icons.person, size: 60, color: Colors.white54)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => _changeAvatar(controller),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.phone,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SECTION 1: PERSONAL INFORMATION
            _buildSectionCard(
              title: "Personal Information",
              icon: Icons.person_outline,
              children: [
                CustomTextField(controller: _nameController, label: "Full Name", prefixIcon: Icons.assignment_ind),
                const SizedBox(height: 16),
                CustomTextField(controller: _phoneController, label: "Phone Number", prefixIcon: Icons.phone_android, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                CustomTextField(controller: _emailController, label: "Email Address", prefixIcon: Icons.email, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: _dobController, label: "Date of Birth", prefixIcon: Icons.cake)),
                    const SizedBox(width: 16),
                    Expanded(child: CustomTextField(controller: _genderController, label: "Gender", prefixIcon: Icons.wc)),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(controller: _addressController, label: "Address", prefixIcon: Icons.home),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: _cityController, label: "City", prefixIcon: Icons.location_city)),
                    const SizedBox(width: 16),
                    Expanded(child: CustomTextField(controller: _stateController, label: "State", prefixIcon: Icons.map_outlined)),
                  ],
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "SAVE PERSONAL INFO",
                  color: AppColors.secondary,
                  onPressed: () async {
                    final success = await controller.savePersonalInfo(
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      email: _emailController.text.trim(),
                      dob: _dobController.text.trim(),
                      gender: _genderController.text.trim(),
                      address: _addressController.text.trim(),
                      city: _cityController.text.trim(),
                      state: _stateController.text.trim(),
                    );
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ Personal info updated successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SECTION 2: EMERGENCY CONTACTS
            _buildSectionCard(
              title: "Emergency Contacts",
              icon: Icons.contact_phone_outlined,
              children: [
                if (controller.contacts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("No emergency contacts saved.", style: TextStyle(color: Colors.white60)),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.contacts.length,
                    itemBuilder: (context, index) {
                      final c = controller.contacts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.favorite, color: AppColors.secondary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c['name']!,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${c['relation']} • ${c['phone']}",
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () {
                                controller.removeEmergencyContact(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.secondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => _showAddContactDialog(controller),
                  icon: const Icon(Icons.add, color: AppColors.secondary),
                  label: const Text("ADD EMERGENCY CONTACT", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SECTION 3: MEDICAL DETAILS
            _buildSectionCard(
              title: "Medical Details",
              icon: Icons.medical_services_outlined,
              children: [
                CustomTextField(controller: _bloodController, label: "Blood Group", prefixIcon: Icons.bloodtype),
                const SizedBox(height: 16),
                CustomTextField(controller: _conditionsController, label: "Chronic Conditions", prefixIcon: Icons.health_and_safety_outlined),
                const SizedBox(height: 16),
                CustomTextField(controller: _allergiesController, label: "Allergies", prefixIcon: Icons.warning_amber_rounded),
                const SizedBox(height: 20),
                CustomButton(
                  text: "SAVE MEDICAL DETAILS",
                  color: AppColors.secondary,
                  onPressed: () async {
                    final success = await controller.saveMedicalDetails(
                      bloodGroup: _bloodController.text.trim(),
                      conditions: _conditionsController.text.trim(),
                      allergies: _allergiesController.text.trim(),
                    );
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ Medical details updated successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SECTION 4: SAFETY SETTINGS
            _buildSectionCard(
              title: "Safety Settings",
              icon: Icons.shield_outlined,
              children: [
                _buildSwitchTile(
                  title: "Shake SOS Trigger",
                  subtitle: "Shake phone aggressively to launch emergency alert",
                  value: controller.shakeSos,
                  onChanged: (val) {
                    controller.setShakeSos(val);
                  },
                ),
                _buildSwitchTile(
                  title: "Voice SOS Mode",
                  subtitle: "Trigger alert using high-frequency scream or words",
                  value: controller.voiceSos,
                  onChanged: (val) {
                    controller.setVoiceSos(val);
                  },
                ),
                _buildSwitchTile(
                  title: "Auto Audio Record",
                  subtitle: "Start recording surrounding audio when SOS hits",
                  value: controller.autoRecord,
                  onChanged: (val) {
                    controller.setAutoRecord(val);
                  },
                ),
                _buildSwitchTile(
                  title: "Live GPS Tracking",
                  subtitle: "Share real-time locations periodically with guards",
                  value: controller.liveTracking,
                  onChanged: (val) {
                    controller.setLiveTracking(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SECTION 5: SECURITY SETTINGS
            _buildSectionCard(
              title: "Security Settings",
              icon: Icons.lock_outline,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fingerprint, color: AppColors.secondary),
                  title: const Text("Biometric Authentication", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Unlock app using Fingerprint / Face ID", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  trailing: Switch(
                    value: true,
                    onChanged: (val) {},
                    activeThumbColor: AppColors.secondary,
                  ),
                ),
                const Divider(color: AppColors.border),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.pin, color: AppColors.secondary),
                  title: const Text("Secure PIN Lock", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("4-digit validation PIN code configuration", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🔒 Secure App PIN manager loaded")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // LOGOUT BUTTON
            CustomButton(
              text: "LOG OUT SESSION",
              color: Colors.redAccent,
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    title: const Text("Confirm Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    content: const Text("Are you sure you want to end this login session?", style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CANCEL", style: TextStyle(color: Colors.white70)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () async {
                          Navigator.pop(context);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('is_logged_in', false);
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text("LOGOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Expansion tile builder
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.white54,
          iconColor: AppColors.secondary,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.secondary, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          children: children,
        ),
      ),
    );
  }

  // Switch list tile builder
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.secondary,
          activeTrackColor: AppColors.secondary.withValues(alpha: 0.3),
        ),
        const Divider(color: AppColors.border),
      ],
    );
  }
}
