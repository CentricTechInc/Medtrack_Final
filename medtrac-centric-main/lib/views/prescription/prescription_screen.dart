
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/prescription_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_dropdown_field.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:signature/signature.dart';
import 'widgets/date_picker_field.dart';
import 'widgets/drug_details_field.dart';

class PrescriptionScreen extends GetView<PrescriptionController> {
  const PrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'E Prescription',
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadingTextTwo(text: "Patient Information"),
                16.verticalSpace,
                BodyTextOne(
                  text: "Full Name",
                ),
                8.verticalSpace,
                CustomTextFormField(
                  hintText: "Enter Patient Name",
                  controller: controller.patientNameController,
                ),
                16.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyTextOne(text: "Age"),
                          8.verticalSpace,
                          CustomTextFormField(
                            hintText: "Enter Age",
                            controller: controller.ageController,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyTextOne(
                            text: "Gender",
                          ),
                          8.verticalSpace,
                          Obx(() {
                            return CustomDropdownField(
                              hintText: "Gender",
                              value: controller.selectedGender.value.isEmpty
                                  ? null
                                  : controller.selectedGender.value,
                              items: controller.genderOptions,
                              onChanged: controller.setGender,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                32.verticalSpace,
                HeadingTextTwo(text: "Prescription Details"),
                16.verticalSpace,
                BodyTextOne(
                  text: "Date of Prescription",
                ),
                8.verticalSpace,
                Obx(() => DatePickerField(
                  selectedDate: controller.selectedDate.value,
                  onDateChanged: (date) {
                    controller.setDate(date);
                  },
                )),
                16.verticalSpace,
                BodyTextOne(
                  text: "Drug Name / Strength / Frequency",
                ),
                8.verticalSpace,
                Obx(() => DrugDetailsField(
                  drugName: controller.drugName.value.isEmpty ? null : controller.drugName.value,
                  strength: controller.strength.value.isEmpty ? null : controller.strength.value,
                  frequency: controller.frequency.value.isEmpty ? null : controller.frequency.value,
                  onChanged: (name, strength, frequency) {
                    controller.setDrugDetails(name, strength, frequency);
                  },
                )),

                16.verticalSpace,
                BodyTextOne(
                  text: "Instructions",
                ),
                8.verticalSpace,
                CustomTextFormField(
                  hintText: "Enter Instructions",
                  controller: controller.instructionsController,
                  maxLines: 5,
                ),
                16.verticalSpace,
                CustomElevatedButton(
                  text: "Add More",
                  onPressed: () {},
                  isOutlined: true,
                ),
                16.verticalSpace,
                Row(
                  children: [
                    BodyTextOne(text: "Recommended Tests"),
                    4.horizontalSpace,
                    CustomText(
                      text: "(Optional)",
                      fontSize: 12,
                    ),
                  ],
                ),
                8.verticalSpace,
                _RecommendedTestsInput(),
                16.verticalSpace,
                BodyTextOne(text: "E-Signature"),
                8.verticalSpace,
                SignatureField(),
                24.verticalSpace,
                Obx(() => CustomElevatedButton(
                  text: "Send",
                  onPressed: controller.isSubmitting.value
                      ? () {} // Empty callback when loading
                      : () => controller.submitPrescription(),
                  isLoading: controller.isSubmitting.value,
                )),
                50.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignatureField extends StatelessWidget {
  const SignatureField({super.key});

  PrescriptionController get controller => Get.find();

  void _showSignaturePad(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SignaturePadSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSignaturePad(context),
      child: Obx(() {
        final image = controller.signatureImage.value;
        return Container(
          width: double.infinity,
          height: 150.h,
          decoration: BoxDecoration(
            color: AppColors.bright,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.greyBackgroundColor),
          ),
          child: Center(
            child: image == null
                ? Text(
                    "Tap to add signature",
                    style: TextStyle(color: AppColors.lightGreyText),
                  )
                : Image.memory(image, height: 100.h),
          ),
        );
      }),
    );
  }
}

class SignaturePadSheet extends StatefulWidget {
  const SignaturePadSheet({super.key});

  @override
  State<SignaturePadSheet> createState() => _SignaturePadSheetState();
}

class _SignaturePadSheetState extends State<SignaturePadSheet> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.secondary,
    exportBackgroundColor: AppColors.bright,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
  }

  PrescriptionController get controller => Get.find();

  Future<void> _save() async {
    if (_controller.isNotEmpty) {
      final image = await _controller.toPngBytes();
      if (image != null) {
        controller.signatureImage.value = image;
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BodyTextOne(
              text: "Draw your signature",
            ),
            16.verticalSpace,
            Container(
              height: 220.h,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.greyBackgroundColor),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.transparent,
              ),
            ),
            16.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: _save,
                    text: 'Save',
                    isSecondary: true,
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: _clear,
                    text: 'Clear',
                    isOutlined: true,
                    isSecondary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedTestsInput extends StatefulWidget {
  _RecommendedTestsInput();

  @override
  _RecommendedTestsInputState createState() => _RecommendedTestsInputState();
}

class _RecommendedTestsInputState extends State<_RecommendedTestsInput> {
  PrescriptionController get controller => Get.find();
  final FocusNode _focusNode = FocusNode();
  bool _updating = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _formatBullets(String text) {
    final lines = text.split('\n');
    return lines.map((line) {
      final trimmed = line.trimLeft();
      if (trimmed.isEmpty) return '';
      return trimmed.startsWith('• ') ? trimmed : '• $trimmed';
    }).join('\n');
  }

  void _onChanged(String value) {
    if (_updating) return;
    _updating = true;
    final selection = controller.recommendedTestsController.selection;
    final formatted = _formatBullets(value);
    controller.recommendedTestsController.value = TextEditingValue(
      text: formatted,
      selection: selection.copyWith(
        baseOffset: formatted.length,
        extentOffset: formatted.length,
      ),
    );
    _updating = false;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.recommendedTestsController,
      focusNode: _focusNode,
      keyboardType: TextInputType.multiline,
      minLines: 3,
      maxLines: 8,
      textInputAction: TextInputAction.newline,
      onChanged: _onChanged,
      style: const TextStyle(color: AppColors.secondary),
      decoration: InputDecoration(
        hintText: "Enter Recommended Tests",
        filled: true,
        fillColor: AppColors.bright,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.greyBackgroundColor),
        ),
      ),
    );
  }
}
