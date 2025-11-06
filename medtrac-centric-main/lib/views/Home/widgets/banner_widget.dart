import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBannerWidget extends StatelessWidget {
  final String text; // String for dynamic text

  const CustomBannerWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BannerClipper(),
      child: Container(
        color: const Color(0xFF3B7DED), // Blue color matching the image
        height: 50, // Height matching the image
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          text,
          style:  TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class BannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start at the top-left corner
    path.moveTo(0, 0);

    // Top edge
    path.lineTo(size.width, 0);

    // Right triangular cutout
    path.lineTo(size.width - 20, size.height / 2);
    path.lineTo(size.width, size.height);

    // Bottom edge
    path.lineTo(0, size.height);

    // Left triangular cutout
    path.lineTo(20, size.height / 2);
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
