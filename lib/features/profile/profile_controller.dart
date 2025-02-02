import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/profile/data/profile_model.dart';

class ProfileController extends GetxController {
  // Profile 상태 관리
  var profile = Rxn<Profile>(); // 로드된 Profile 데이터
  var isLoading = false.obs;    // 로딩 상태
  var errorMessage = ''.obs;    // 에러 메시지 (필요한 경우)

  Future<void> fetchProfileById(String userId) async {
    // Fetch and update profile data based on userId
  }

  // Profile 데이터 로드
  Future<void> fetchProfile() async {
    isLoading.value = true; // 로딩 시작
    errorMessage.value = ''; // 기존 에러 초기화

    try {
      // 여기에 API 호출 또는 데이터 로드 로직 추가
      // 예: 2초 대기 후 샘플 데이터 로드
      await Future.delayed(const Duration(seconds: 2));

      profile.value = Profile(
        user: User(
          id: "01ba12d0-da6a-45e0-8535-6d2e49a4f96e",
          username: "user_006",
          email: "user006@example.com",
          isLawyer: true,
          profilePictureUrl: "https://example.com/profiles/6.png",
          bio: "Hello, I am user 006!",
          country: "South Korea",
          status: "offline",
          createdAt: DateTime.parse("2025-01-21T07:34:22.62714+00:00"),
          updatedAt: DateTime.parse("2025-01-21T07:34:22.62714+00:00"),
        ),
        lawyerProfile: LawyerProfile(
          lawyerProfileId: "01ba12d0-da6a-45e0-8535-6d2e49a4f96e",
          practiceAreas: null,
          education: null,
          lawFirm: "Firm A",
          biography: "Experienced corporate lawyer",
          certifications: null,
          languages: null,
          isVerified: true,
        ),
        lawyerLicenses: [
          LawyerLicense(
            licenseId: "aca7865a-8915-4f26-ab84-73745bce3446",
            licenseCountry: "USA",
            licenseState: "California",
            licenseYear: 2020,
            licenseTitle: "Senior Lawyer",
            createdAt: DateTime.parse("2023-01-01T10:00:00+00:00"),
            updatedAt: DateTime.parse("2023-01-10T15:00:00+00:00"),
          ),
        ],
      );
    } catch (e) {
      errorMessage.value = 'Failed to load profile'; // 에러 메시지 업데이트
    } finally {
      isLoading.value = false; // 로딩 종료
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchProfile(); // 컨트롤러 초기화 시 데이터 로드
  }
}
