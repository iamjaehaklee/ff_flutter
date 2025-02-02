import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController(this.authRepository) {
    print("🟢 AuthController initialized");
  }

  var isLoading = false.obs;
  var currentUser = Rxn<User>();  // Rxn to hold current user

  // Reactive userId that listens to changes in currentUser
  Rx<String?> userId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    print("🔄 onInit called in AuthController");

    currentUser.value = authRepository.getCurrentUser();
    print("🟢 Current User onInit: ${currentUser.value?.email ?? 'No user logged in'}");

    // Update userId reactively based on currentUser
    if (currentUser.value != null) {
      userId.value = currentUser.value!.id;
    }

    // Listen for auth state changes (e.g., login, logout)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      await refreshUser();
      print("🔄 Auth state changed: ${currentUser.value?.email ?? 'User logged out'}");

      // Update userId based on currentUser after auth state change
      if (currentUser.value != null) {
        userId.value = currentUser.value!.id;
      } else {
        userId.value = null;  // Clear userId on logout
      }

      if (currentUser.value == null) {
        print("🔴 User logged out. Redirecting to /login");
        _navigateToLogin();
      } else if (!isEmailConfirmed()) {
        print("⚠️ Email is not confirmed. Redirecting to /verify-email.");
        Get.offAllNamed('/verify-email');
      }
    });
  }
// ✅ 이메일 인증 이메일 재발송
  Future<void> resendVerificationEmail(String email) async {
    try {
      print("🔄 Resending verification email to: $email");

      // ✅ Supabase에서 이메일 인증 이메일을 다시 보내려면 `signUp`을 다시 호출
      await Supabase.instance.client.auth.signUp(email: email, password: "dummy_password");

      print("✅ Verification email resent successfully");
    } catch (e) {
      print("❌ Failed to resend verification email: $e");
    }
  }

  // ✅ 이메일 인증 상태 확인
  bool isEmailConfirmed() {
    final user = currentUser.value;
    return user != null && user.emailConfirmedAt != null;
  }

  // ✅ 사용자 정보 새로고침
  Future<void> refreshUser() async {
    try {
      final newUser = await Supabase.instance.client.auth.getUser();
      if (newUser.user != null) {
        currentUser.value = newUser.user;
        print("🔄 User refreshed: ${currentUser.value?.email}, Email Confirmed: ${currentUser.value?.emailConfirmedAt != null}");
      }
    } catch (e) {
      print("❌ Error refreshing user: $e");
    }
  }

  // ✅ 네비게이션 실행 (로그인 페이지로 이동)
  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.offAllNamed('/login');
      } else {
        print("⚠️ Still no Get.context available. Retrying in 100ms...");
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.context != null) {
            Get.offAllNamed('/login');
          } else {
            print("❌ Navigation failed: Get.context is still null!");
          }
        });
      }
    });
  }

  // ✅ 이메일 로그인
  Future<void> signInWithEmail(String email, String password) async {
    try {
      print("🔄 Attempting to sign in with email: $email");
      isLoading(true);
      await authRepository.signInWithEmail(email, password);
      await refreshUser();

      if (currentUser.value != null) {
        if (!isEmailConfirmed()) {
          print("⚠️ Email is not confirmed. Redirecting to /verify-email.");
          Get.offAllNamed('/verify-email');
        } else {
          print("✅ Login successful: ${currentUser.value!.email}");
          Get.offAllNamed('/main');
        }
      } else {
        print("❌ Login failed: No user returned from Supabase");
        Get.snackbar("Login Failed", "No user information received.");
      }
    } catch (e) {
      print("❌ Login error: $e");
      Get.snackbar("Login Failed", e.toString(), backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // ✅ 이메일 회원가입 (회원가입 후 "이메일 확인" 페이지로 이동)
  // ✅ 이메일 회원가입 (회원가입 후 "이메일 확인" 페이지로 이동)
  // ✅ 이메일 회원가입 (회원가입 후 "이메일 확인" 페이지로 이동)
  Future<void> signUpWithEmail(String email, String password, String username, String firstName, String lastName) async {
    try {
      print("🔄 Signing up with email: $email, username: $username, firstName: $firstName, lastName: $lastName");
      isLoading(true);
      await authRepository.signUpWithEmail(email, password, username, firstName, lastName);
      print("✅ Registration successful. Redirecting to verify-email page.");

      Get.snackbar(
        "Success",
        "A verification email has been sent to your inbox. Please verify your email before logging in.",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      // ✅ 회원가입 후 이메일 인증 안내 페이지로 이동
      Get.offAllNamed('/verify-email');
    } catch (e) {
      print("❌ Registration error: $e");
      Get.snackbar("Registration Failed", e.toString(), backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }



  // ✅ 비밀번호 재설정 요청
  Future<void> resetPassword(String email) async {
    try {
      print("🔄 Requesting password reset for: $email");
      isLoading(true);
      await authRepository.resetPassword(email);
      print("✅ Password reset email sent to: $email");

      Get.snackbar("Success", "Password reset email sent.", backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
    } catch (e) {
      print("❌ Password reset error: $e");
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // ✅ 로그아웃
  Future<void> signOut() async {
    print("🔄 Signing out user: ${currentUser.value?.email ?? 'Unknown user'}");
    await authRepository.signOut();
    currentUser.value = null;
    userId.value = null;  // Clear the reactive userId on sign out
    print("🔴 User signed out. Redirecting to /login");
    Get.offAllNamed('/login');
  }

  // ✅ 현재 로그인한 사용자의 ID 반환
  String? getUserId() {
    print("🔄 Fetching user ID: ${currentUser.value?.id ?? 'No user'}");
    return currentUser.value?.id;
  }

  // ✅ 회원 탈퇴 (계정 삭제)
  Future<void> deleteAccount() async {
    try {
      print("🔄 Withdrawing membership for user: ${currentUser.value?.email ?? 'Unknown user'}");
      await Supabase.instance.client.auth.admin.deleteUser(currentUser.value!.id);
      print("✅ Membership withdrawn successfully");
      Get.snackbar("Success", "Your membership has been withdrawn. All data has been deleted.");
      currentUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      print("❌ Membership withdrawal failed: $e");
      Get.snackbar("Error", "Failed to withdraw membership. Try again.");
    }
  }

}
