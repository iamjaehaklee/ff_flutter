import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/app/app_theme.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/agreement/presentation/privacy_polity_page.dart';
import 'package:legalfactfinder2025/features/agreement/presentation/term_of_service_page.dart';
import '../auth_controller.dart';

class RegisterPage extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController(); // ✅ 추가
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  // ✅ 체크박스 상태 관리
  final RxBool agreeToTerms = false.obs;
  final RxBool agreeToPrivacy = false.obs;
  final RxBool agreeToMarketing = false.obs;

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // ✅ 스크롤 가능하도록 변경
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0), // ✅ 위아래 패딩 유지
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text(appTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(appSubtitle, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: usernameController, // ✅ username 입력 필드 추가
                decoration: const InputDecoration(labelText: "Username"),
              ),
              const SizedBox(height: 15),
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

              Divider(),

              const SizedBox(height: 25),



              TextField(
                controller: firstNameController, // ✅ first_name 입력 필드 추가
                decoration: const InputDecoration(labelText: "First Name"),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: lastNameController, // ✅ last_name 입력 필드 추가
                decoration: const InputDecoration(labelText: "Last Name"),
              ),
              const SizedBox(height: 25),

              Divider(),

              const SizedBox(height: 25),

              // ✅ 약관 동의 체크박스 (패딩 축소)
              Obx(() => CheckboxListTile(
                value: agreeToTerms.value,
                onChanged: (value) => agreeToTerms.value = value!,
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 2, // ✅ 요소 간 여백 최소화
                  children: [
                    const Text("I agree to the "),
                    GestureDetector(
                      onTap: () => Get.to(() => TermsOfServicePage()),
                      child: const Text("Terms of Service", style: AppTheme.interactiveTextStyle),
                    ),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0), // ✅ 좌우 패딩 절반 축소
              )),

              Obx(() => CheckboxListTile(
                value: agreeToPrivacy.value,
                onChanged: (value) => agreeToPrivacy.value = value!,
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 2, // ✅ 요소 간 여백 최소화
                  children: [
                    const Text("I agree to the "),
                    GestureDetector(
                      onTap: () => Get.to(() => PrivacyPolicyPage()),
                      child: const Text("Privacy Policy", style: AppTheme.interactiveTextStyle),
                    ),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0), // ✅ 좌우 패딩 절반 축소
              )),

              Obx(() => CheckboxListTile(
                value: agreeToMarketing.value,
                onChanged: (value) => agreeToMarketing.value = value!,
                title: const Text("I agree to receive marketing emails and promotions (optional)"),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0), // ✅ 좌우 패딩 절반 축소
              )),

              const SizedBox(height: 10),

              // ✅ 회원가입 버튼 (필수 동의 항목 확인)
              Obx(() {
                final isButtonEnabled = agreeToTerms.value && agreeToPrivacy.value;

                return authController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity, // ✅ 버튼 너비 확장
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? () {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      final username = usernameController.text.trim();
                      final lastName = lastNameController.text.trim();
                      final firstName = firstNameController.text.trim();

                      if (email.isEmpty || password.isEmpty||username.isEmpty) {
                        Get.snackbar("Error", "Username, email and password cannot be empty");
                        return;
                      }

                      authController.signUpWithEmail(email, password,username, firstName, lastName);
                    } : null,
                    child: const Text("Sign Up"),
                  ),
                );
              }),

              const SizedBox(height: 10),

              Center(
                child: TextButton(
                  onPressed: () => Get.offNamed('/login'),
                  child: const Text("Already have an account? Log in", style: AppTheme.interactiveTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
