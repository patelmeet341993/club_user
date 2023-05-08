import 'package:club_model/club_model.dart';
import 'package:flutter/material.dart';

import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/authentication/authentication_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with MySafeState {
  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              AuthenticationController(authenticationProvider: context.read<AuthenticationProvider>()).logout(isNavigateToLogin: true);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
