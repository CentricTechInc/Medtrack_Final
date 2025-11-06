import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SearchBarController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  
  final RxList<String> originalList = <String>[].obs;
  final RxList<String> filteredList = <String>[].obs;

  void setList(List<String> items) {
    originalList.assignAll(items);
    filteredList.assignAll(items);
  }

  void onChanged(String value) {
    if (value.isEmpty) {
      filteredList.assignAll(originalList);
    } else {
      filteredList.assignAll(
        originalList.where((item) => item.toLowerCase().contains(value.toLowerCase())),
      );
    }
  }

  void clearSearch() {
    textEditingController.clear();
    filteredList.assignAll(originalList);
  }
}
