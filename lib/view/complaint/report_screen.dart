import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../controller/complaint_controller.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'complaint_history.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  String _selectedCategory = 'Cyber Blackmailing (Photo/Video)';
  bool _isUploading = false;

  final List<String> _categories = [
    'Cyber Blackmailing (Photo/Video)',
    'Online Stalking/Harassment',
    'Fake Identity Profile Abuse',
    'Morphed Image Sharing',
    'Financial Extortion / Threat',
  ];

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;

  Future<void> _pickEvidence() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          _selectedFile = file;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("📄 Evidence attached: ${file.name}"),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      print("Error picking evidence: $e");
    }
  }

  void _submitIncident() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      final complaintController = Provider.of<ComplaintController>(context, listen: false);
      final List<String> localEvidences = [];
      if (_selectedFile != null) {
        localEvidences.add(_selectedFile!.path);
      }

      final success = await complaintController.fileComplaint(
        type: _selectedCategory,
        description: _descController.text.trim(),
        evidences: localEvidences,
      );

      if (mounted) {
        setState(() => _isUploading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🚨 Complaint submitted successfully to Cyber Cell queue!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ComplaintHistoryScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ Failed to submit complaint. Please check your network and try again."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Cyber Complaint Vault", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "File Secure Incident Report",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Upload details securely. Evidences are encrypted directly inside cloud database storage.",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Category of Abuse",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: AppColors.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descController,
                label: "Detailed Incident Description",
                prefixIcon: Icons.description,
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              
              // Attachment Card Mock
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    if (_selectedFile == null) ...[
                      const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.secondary),
                      const SizedBox(height: 8),
                      const Text("Upload Evidence Documents", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text("Supports Screenshot, Chat PDF, Voice or Video recording", style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ] else ...[
                      const Icon(Icons.check_circle_outline, size: 40, color: Colors.greenAccent),
                      const SizedBox(height: 8),
                      const Text("Evidence File Attached Successfully", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          color: AppColors.border,
                          child: Image.file(
                            File(_selectedFile!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFile!.name,
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _pickEvidence,
                      icon: Icon(_selectedFile == null ? Icons.add : Icons.sync, color: AppColors.secondary),
                      label: Text(
                        _selectedFile == null ? "ATTACH EVIDENCE" : "CHANGE FILE",
                        style: const TextStyle(color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "SUBMIT REPORT",
                isLoading: _isUploading,
                color: AppColors.secondary,
                onPressed: _submitIncident,
              )
            ],
          ),
        ),
      ),
    );
  }
}