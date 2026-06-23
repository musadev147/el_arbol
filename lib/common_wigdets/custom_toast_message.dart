import 'package:flutter/material.dart';
import 'package:get/get.dart';


SnackbarController customToastMessage(String title, String description) {
  return Get.snackbar(title, description,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xff444444),
      colorText: Colors.white,
      );
}