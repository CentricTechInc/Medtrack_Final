import 'package:get/get.dart';

class SharedController extends GetxController{
  void onTabChanged(int index){
    currentTab.value = index;
  }
  RxInt currentTab = 0.obs;
}