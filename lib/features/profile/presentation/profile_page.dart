import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/profile/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final userId = Get.arguments; // Retrieve the passed userId
    profileController.fetchProfileById(userId); // Fetch profile by userId

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (profileController.errorMessage.value.isNotEmpty) {
          return Center(child: Text(profileController.errorMessage.value));
        }

        final profile = profileController.profile.value;
        if (profile == null) {
          return Center(child: Text('Profile not found'));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(profile.user.profilePictureUrl),
                    ),
                    SizedBox(height: 20),
                    Text(
                      profile.user.username,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(profile.user.email, style: TextStyle(fontSize: 16, color: Colors.grey)),
                    SizedBox(height: 10),
                    Text(profile.user.bio, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    if (profile.user.isLawyer)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Lawyer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ListTile(
                            title: Text('Law Firm'),
                            subtitle: Text(profile.lawyerProfile?.lawFirm ?? 'N/A'),
                          ),
                          ListTile(
                            title: Text('Biography'),
                            subtitle: Text(profile.lawyerProfile?.biography ?? 'N/A'),
                          ),
                          ListTile(
                            title: Text('Verified'),
                            subtitle: Text(profile.lawyerProfile?.isVerified == true ? 'Yes' : 'No'),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Licenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ...?profile.lawyerLicenses?.map((license) => ListTile(
                            title: Text(license.licenseTitle),
                            subtitle: Text('${license.licenseCountry}, ${license.licenseState} (${license.licenseYear})'),
                          )),
                        ],
                      ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // 채팅하기 로직
                    },
                    icon: Icon(Icons.chat),
                    label: Text('Chat'),
                    style: ElevatedButton.styleFrom(minimumSize: Size(140, 50)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 전화걸기 로직
                    },
                    icon: Icon(Icons.call),
                    label: Text('Call'),
                    style: ElevatedButton.styleFrom(minimumSize: Size(140, 50)),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
