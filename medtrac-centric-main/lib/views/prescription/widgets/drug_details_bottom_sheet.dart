import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';

class DrugDetailsBottomSheet extends StatelessWidget {
  final void Function(String, String, String) onSave;
  const DrugDetailsBottomSheet({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final strengthController = TextEditingController();
    final frequencyController = TextEditingController();
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter Drug Details", style: TextStyle(fontWeight: FontWeight.bold)),
            16.verticalSpace,
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Drug Name'),
            ),
            8.verticalSpace,
            TextField(
              controller: strengthController,
              decoration: const InputDecoration(labelText: 'Strength'),
            ),
            8.verticalSpace,
            TextField(
              controller: frequencyController,
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),
            16.verticalSpace,
            ElevatedButton(
              onPressed: () {
                onSave(
                  nameController.text,
                  strengthController.text,
                  frequencyController.text,
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
