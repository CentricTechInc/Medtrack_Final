import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_general_notfication.dart';

void showNotificationBar({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 3),
  double? topPadding,
  double? horizontalMargin,
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      top: topPadding ?? 20.h,
      left: horizontalMargin ?? 20.w,
      right: horizontalMargin ?? 20.w,
      child: Material(
        color: Colors.transparent,
        child: GeneralNotification(message: message),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
