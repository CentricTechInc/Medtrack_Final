import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/snackbar.dart';

class ExplainProblemInputWidget extends StatefulWidget {
     final TextEditingController controller;
     

   const ExplainProblemInputWidget({super.key , required this.controller});



  @override
  State<ExplainProblemInputWidget> createState() =>
      _ExplainProblemInputWidgetState();
}

class _ExplainProblemInputWidgetState extends State<ExplainProblemInputWidget> {
  bool _isPicking = false;

  late final TextEditingController _controller;
@override
void initState() {
  super.initState();
  _controller = widget.controller;
}
  
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  void _insertBullet() {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      "• ",
    );

    setState(() {
      _controller.text = newText;
      _controller.selection =
          TextSelection.collapsed(offset: selection.start + 2);
    });
  }

  void _insertLink() async {
    final url = await showDialog<String>(
      context: context,
      builder: (context) {
        final linkController = TextEditingController();
        return AlertDialog(
          title: Text('Insert Link'),
          content: TextField(
            controller: linkController,
            decoration: InputDecoration(hintText: 'Enter URL'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, linkController.text),
              child: Text('Insert'),
            ),
          ],
        );
      },
    );

    if (url != null && url.isNotEmpty) {
      final selection = _controller.selection;
      final newText = _controller.text.replaceRange(
        selection.start,
        selection.end,
        url,
      );
      setState(() {
        _controller.text = newText;
        _controller.selection =
            TextSelection.collapsed(offset: selection.start + url.length);
      });
    }
  }

void _pickImage() async {
  if (_isPicking) return; // Prevent multiple triggers
  _isPicking = true;

  try {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
      });
      SnackbarUtils.showInfo("${pickedFiles.length} image(s) selected.");
    }
  } catch (e) {
    SnackbarUtils.showError("Failed to pick images: $e");
  } finally {
    _isPicking = false;
  }
}


void _removeImage(int index) {
  setState(() {
    _selectedImages.removeAt(index);
  });
}


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: TextField(
              controller: _controller,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "Type your Query here",
                hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.dark),
                border: InputBorder.none,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.borderGrey),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.format_list_bulleted, size: 20.sp),
                  onPressed: _insertBullet,
                ),
                IconButton(
                  icon: Icon(Icons.link, size: 20.sp),
                  onPressed: _insertLink,
                ),
                IconButton(
                  icon: Icon(Icons.image, size: 20.sp),
                  onPressed: _pickImage,
                ),
              ],
            ),
          ),
         if (_selectedImages.isNotEmpty)
  Padding(
    padding: EdgeInsets.symmetric(horizontal: 12.w),
    child: SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                margin: EdgeInsets.only(right: 8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(
                    _selectedImages[index],
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: CircleAvatar(
                    radius: 10.r,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 12.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  ),

        ],
      ),
    );
  }
}
