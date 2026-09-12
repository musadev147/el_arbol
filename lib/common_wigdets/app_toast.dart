import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';

class AppToast {
  AppToast._();

  static void _show({
    required String message,
    required List<Color> gradient,
    required IconData icon,
  }) {
    String cleanMessage = message.trim();
    if (cleanMessage.contains('<!DOCTYPE') ||
        cleanMessage.contains('<html') ||
        cleanMessage.contains('Traceback (most recent call last)')) {
      cleanMessage = 'A server error occurred. Please try again later.';
    }
    if (cleanMessage.length > 200) {
      cleanMessage = '${cleanMessage.substring(0, 197)}...';
    }

    Get.closeAllSnackbars();

    Get.showSnackbar(GetSnackBar(
      messageText: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                cleanMessage,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      padding: EdgeInsets.zero,
      barBlur: 0,
      boxShadows: const [], // Explicitly remove default GetX shadows
      duration: const Duration(seconds: 3),
      isDismissible: true,
    ));
  }

  /// 🟢 Premium Green (Matches App Theme Color)
  static void success(String message, {List<Color>? gradient}) {
    _show(
      message: message,
      icon: Icons.check,
      gradient: gradient ??
          const [
            Color(0xFF00875A),
            AppColors.primaryGreen,
          ],
    );
  }

  /// 🔴 Premium Red
  static void error(String message) {
    _show(
      message: message,
      icon: Icons.close,
      gradient: const [
        Color(0xFFFF7A7A),
        Color(0xFFE63946),
      ],
    );
  }

  /// ⚪ Premium Grey
  static void info(String message) {
    _show(
      message: message,
      icon: Icons.info_outline,
      gradient: const [
        Color(0xFF7A7A7A),
        Color(0xFF4F4F4F),
      ],
    );
  }
}