import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient supabase;

  AuthRepository(this.supabase);

  // 이메일 로그인
  Future<void> signInWithEmail(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

   // ✅ 이메일 회원가입 (provider 추가)
  Future<void> signUpWithEmail(String email, String password, String username, String firstName, String lastName) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'provider': 'email',  // ✅ provider 값을 명시적으로 추가
      },
    );
  }
  // 비밀번호 재설정 이메일 전송
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  // 현재 로그인된 사용자 가져오기
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // 로그아웃
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}