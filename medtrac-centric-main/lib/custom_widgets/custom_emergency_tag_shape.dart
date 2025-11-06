import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(64.8809, 18.6836);
    path_0.lineTo(64.8809, 32.0002);
    path_0.cubicTo(66.1788, 31.9659, 69.2182, 31.7406, 72.0767, 30.0777);
    path_0.cubicTo(73.4908, 29.2548, 74.4176, 28.4033, 75, 27.7084);
    path_0.lineTo(75, 18.6836);
    path_0.lineTo(64.8809, 18.6836);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Color(0xffFB2C36).withValues(alpha: 1.0);
    canvas.drawPath(path_0, paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(75, 27.708);
    path_1.cubicTo(74.3206, 27.0112, 73.2396, 26.112, 71.5838, 25.3025);
    path_1.cubicTo(70.1679, 24.6113, 68.6929, 24.1932, 67.3512, 23.9374);
    path_1.cubicTo(66.1065, 23.7006, 64.9779, 23.6052, 64.1158, 23.5632);
    path_1.cubicTo(55.6676, 23.5632, 47.2195, 23.5632, 38.7694, 23.5632);
    path_1.cubicTo(27.9004, 23.5632, 17.0314, 23.5632, 6.16245, 23.5632);
    path_1.cubicTo(5.49825, 22.2191, 4.83405, 20.875, 4.16794, 19.531);
    path_1.cubicTo(2.77863, 16.7206, 1.38741, 13.9103, -0.00190735, 11.0981);
    path_1.cubicTo(0.104675, 10.9071, 0.209343, 10.7162, 0.315918, 10.5253);
    path_1.cubicTo(1.67097, 8.08535, 3.02413, 5.64731, 4.37918, 3.20736);
    path_1.cubicTo(4.97297, 2.1363, 5.56866, 1.06715, 6.16245, -0.00390625);
    path_1.cubicTo(
        16.5575, -0.00390625, 26.9546, -0.00390625, 37.3496, -0.00390625);
    path_1.cubicTo(
        46.6047, -0.00390625, 55.8618, -0.00390625, 65.1169, -0.00390625);
    path_1.cubicTo(
        65.1378, -0.00390625, 65.1587, -0.00390625, 65.1778, -0.00390625);
    path_1.cubicTo(67.8822, 0.0132765, 70.3277, 1.1187, 72.1034, 2.89807);
    path_1.cubicTo(72.9008, 3.69802, 73.5612, 4.63353, 74.0503, 5.6664);
    path_1.cubicTo(74.6593, 6.95701, 75, 8.39464, 75, 9.91245);
    path_1.cubicTo(75, 11.1439, 75, 12.3734, 75, 13.6048);
    path_1.cubicTo(75, 16.8543, 75, 20.1037, 75, 23.3513);
    path_1.cubicTo(75, 24.8022, 75, 26.2551, 75, 27.708);
    path_1.close();

    Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    paint1Fill.color = Color(0xffFF6467).withValues(alpha: 1.0);
    canvas.drawPath(path_1, paint1Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}