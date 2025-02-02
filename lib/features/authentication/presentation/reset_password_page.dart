import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/app/app_theme.dart';
import 'package:legalfactfinder2025/constants.dart';
import '../auth_controller.dart';

class ResetPasswordPage extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();

  ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Text(appTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(appSubtitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 25),
            Obx(() {
              return authController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () {
                  authController.resetPassword(emailController.text);
                },
                child: const Center(child: Text("Send Reset Email")),
              );
            }),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.offNamed('/login'),
              child: const Text("Back to Login", style: AppTheme.interactiveTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}
