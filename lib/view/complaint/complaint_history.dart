import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../controller/complaint_controller.dart';
import '../../model/complaint_model.dart';

class ComplaintHistoryScreen extends StatelessWidget {
  const ComplaintHistoryScreen({super.key});

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final complaintController = context.watch<ComplaintController>();
    final List<ComplaintModel> history = complaintController.complaintHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Complaint History & Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          complaintController.initComplaintSync();
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: history.isEmpty
            ? Center(
                child: ListView(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text(
                          "No complaints filed yet",
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your submitted incidents will appear here.",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final ComplaintModel item = history[index];
                  final bool isResolved = item.status.toLowerCase() == 'resolved';
                  final String dateStr = "${item.createdAt.day} ${_getMonthName(item.createdAt.month)} ${item.createdAt.year}";

                  return Card(
                    color: AppColors.surface,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.complaintId, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isResolved 
                                      ? Colors.green.withOpacity(0.15) 
                                      : Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.status,
                                  style: TextStyle(
                                    color: isResolved ? Colors.greenAccent : Colors.amberAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.type,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          
                          // Display evidence link if uploaded
                          if (item.evidenceUrls.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.attach_file, size: 14, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  "${item.evidenceUrls.length} Evidence Attachment(s)",
                                  style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 4),
                          Text("Filed Date: $dateStr", style: const TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}