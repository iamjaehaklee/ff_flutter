import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/app/app_theme.dart';
import 'package:legalfactfinder2025/constants.dart';
import '../auth_controller.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    print("🟢 LoginPage loaded");

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ 전체 요소 가운데 정렬
          children: [
            const SizedBox(height: 80),

            // ✅ Legal FactFinder 제목과 슬로건 가운데 정렬
            Center(
              child: Column(
                children: [
                  Text(appTitle, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(appSubtitle, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 25),

            Obx(() {
              return authController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity, // ✅ 버튼 너비 확장
                child: ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      _showAlertDialog(context, "Error", "Email and password cannot be empty.");
                      return;
                    }

                    authController.isLoading.value = true;
                    try {
                      await authController.signInWithEmail(email, password);

                      // ✅ 이메일 인증 여부 확인 후 미인증 시 다이얼로그 표시
                      if (!authController.isEmailConfirmed()) {
                        _showResendEmailDialog(context, email);
                      }
                    } catch (e) {
                      _showAlertDialog(context, "Login Failed", e.toString());
                    } finally {
                      authController.isLoading.value = false;
                    }
                  },
                  child: const Text("Login"),
                ),
              );
            }),
            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text("Don't have an account? Sign up", style: AppTheme.interactiveTextStyle),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/reset-password'),
              child: const Text("Forgot password?", style: AppTheme.interactiveTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 일반 경고 다이얼로그
  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: AppTheme.interactiveTextStyle),
            ),
          ],
        );
      },
    );
  }

  // ✅ 이메일 미인증 시 인증 이메일 재발송 다이얼로그
  void _showResendEmailDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Email Not Verified"),
          content: const Text("Your email has not been verified. Would you like to resend the verification email?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: AppTheme.interactiveTextStyle),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await authController.resendVerificationEmail(email);
                _showAlertDialog(context, "Verification Email Sent", "A new verification email has been sent to your inbox.");
              },
              child: const Text("Yes", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
