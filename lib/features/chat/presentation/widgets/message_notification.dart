import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageNotification {
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
      duration: const Duration(seconds: 2),
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      duration: const Duration(seconds: 3),
    );
  }
}
