import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'drug_details_bottom_sheet.dart';

class DrugDetailsField extends StatelessWidget {
  final String? drugName;
  final String? strength;
  final String? frequency;
  final void Function(String, String, String) onChanged;
  const DrugDetailsField({
    super.key,
    required this.drugName,
    required this.strength,
    required this.frequency,
    required this.onChanged,
  });

  void _showDrugDetailsSheet(BuildContext context) async {
    final result = await Get.bottomSheet<Map<String, String>>(
      DrugDetailsBottomSheet(
        onSave: (name, strength, frequency) {
          Navigator.of(context).pop({
            'drugName': name,
            'strength': strength,
            'frequency': frequency,
          });
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    if (result != null) {
      onChanged(
        result['drugName'] ?? '',
        result['strength'] ?? '',
        result['frequency'] ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDrugDetailsSheet(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.greyBackgroundColor),
        ),
        child: (drugName == null && strength == null && frequency == null)
            ? Text("Drug Name / Strength / Frequency", style: TextStyle(color: AppColors.secondary))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (drugName != null && drugName!.isNotEmpty)
                    Text("Drug: $drugName", style: TextStyle(color: AppColors.secondary)),
                  if (strength != null && strength!.isNotEmpty)
                    Text("Strength: $strength", style: TextStyle(color: AppColors.secondary)),
                  if (frequency != null && frequency!.isNotEmpty)
                    Text("Frequency: $frequency", style: TextStyle(color: AppColors.secondary)),
                ],
              ),
      ),
    );
  }
}
