import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/app/app_theme.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/files/presentation/test_syncfusion_pdf_file_view_page.dart';

class SettingScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Account Settings", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),

          // ✅ 사용자 정보 표시
          Obx(() {
            final user = authController.currentUser.value;
            if (user == null) {
              return const Text("Not logged in", style: AppTheme.defaultTextStyle);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Email: ${user.email ?? 'Unknown'}", style: AppTheme.defaultTextStyle),
                Text("User ID: ${user.id}", style: AppTheme.defaultTextStyle),
                const SizedBox(height: 20),
              ],
            );
          }),

          // ✅ 로그아웃 버튼 (Outline 스타일)
          OutlinedButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Center(child: Text("Log Out")),
          ),
          const SizedBox(height: 10),

          // ✅ 회원 탈퇴 버튼 (빨간색 Outline 스타일)
          OutlinedButton(
            onPressed: () {
              _showWithdrawMembershipDialog(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Center(child: Text("Withdraw Membership")),
          ),

          const SizedBox(height: 10),

          // OutlinedButton(
          //   onPressed: () {
          //     Get.to(() => TestSyncfusionPdfFileViewPage());
          //   },
          //   style: OutlinedButton.styleFrom(
          //     foregroundColor: Colors.green,
          //     side: BorderSide(color: Colors.green, width: 1.5),
          //     padding: EdgeInsets.symmetric(vertical: 14),
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          //   ),
          //   child: Center(child: Text("Open PDF Viewer")),
          // )
        ],
      ),
    );
  }

  // ✅ 로그아웃 확인 다이얼로그
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: AppTheme.interactiveTextStyle),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                authController.signOut();
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ✅ 회원 탈퇴 확인 다이얼로그
  void _showWithdrawMembershipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Withdraw Membership"),
          content: const Text(
              "Are you sure you want to withdraw your membership? "
                  "This will permanently delete your account and all associated data. "
                  "This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: AppTheme.interactiveTextStyle),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await authController.deleteAccount();
              },
              child: const Text("Withdraw", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
