import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(BuildContext context, {required String message, required Color color, IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
        duration: const Duration(milliseconds: 1500),
        elevation: 4,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, color: Colors.green);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, color: Colors.redAccent);
  }
  
  static void showInfo(BuildContext context, String message) {
    show(context, message: message, color: Colors.blueAccent);
  }
}