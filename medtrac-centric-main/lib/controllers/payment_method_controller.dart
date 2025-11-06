import 'package:get/get.dart';
import 'package:medtrac/utils/assets.dart';

class PaymentMethodController extends GetxController {
  RxInt selectedMethodIndex = 0.obs;
  final RxList<Map<String, String>> paymentMethods = <Map<String, String>>[
    {
      "method": "Razorpay",
      "logo": Assets.razorpayLogoImage,
    },
    {
      "method": "Razorpay",
      "logo": Assets.razorpayLogoImage,
    },
  ].obs;
}
