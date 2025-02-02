import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/app/app_theme.dart';
import '../auth_controller.dart';

class VerifyEmailPage extends StatelessWidget {
  final AuthController authController = Get.find();

  VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Text("Verify Your Email", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              "We have sent a verification email to your inbox. Please click the link in the email to complete the verification process.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 40),

            // ✅ 이메일 인증 상태 확인 버튼
            // Center(
            //   child: SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //
            //       onPressed: () async {
            //         await authController.refreshUser();
            //         if (authController.isEmailConfirmed()) {
            //           print("✅ Email verified! Redirecting to main...");
            //           Get.offAllNamed('/main');
            //         } else {
            //           print("❌ Email not verified yet.");
            //           Get.snackbar("Error", "Your email is still not verified. Please check your inbox.");
            //         }
            //       },
            //       child: const Text("Check Verification Status"),
            //     ),
            //   ),
            // ),

            const SizedBox(height: 20),

            // ✅ 다시 로그인 버튼
            Center(
              child: TextButton(
                onPressed: () {
                  authController.signOut();
                  Get.offAllNamed('/login');
                },
                child: const Text("Back to Login", style: AppTheme.interactiveTextStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
