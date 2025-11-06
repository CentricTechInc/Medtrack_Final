import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddPhotoWidget extends StatefulWidget {
  final double height;
  final double borderRadius;
  final void Function(File?)? onImageChanged;
  const AddPhotoWidget({
    super.key,
    this.height = 140,
    this.borderRadius = 12,
    this.onImageChanged,
  });

  @override
  State<AddPhotoWidget> createState() => _AddPhotoWidgetState();
}

class _AddPhotoWidgetState extends State<AddPhotoWidget> {
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes) {
        SnackbarUtils.showError(
            'Image size exceeds 10MB. Please select a smaller image.');
        return;
      }
      setState(() {
        _image = file;
      });
      widget.onImageChanged?.call(_image);
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
    widget.onImageChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: widget.height.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius.r),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: _image == null
              ? GestureDetector(
                  onTap: _pickImage,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.addPictureIcon,
                        fit: BoxFit.contain,
                        scale: 2,
                      ),
                      12.verticalSpace,
                      BodyTextOne(
                        text: 'Add Picture',
                        fontWeight: FontWeight.bold,
                      ),
                      8.verticalSpace,
                      CustomText(
                        text: 'recommended size is 10MB',
                        fontSize: 12.sp,
                        color: AppColors.darkGreyText,
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          _image!,
                          width: 100.w,
                          height: 100.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child:
                              Icon(Icons.close, size: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
