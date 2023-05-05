import 'package:club_model/club_model.dart';
import 'package:club_user/backend/authentication/authentication_controller.dart';
import 'package:club_user/backend/authentication/authentication_provider.dart';
import 'package:flutter/material.dart';

import '../../common/models/home_screen_component_model.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/HomeScreen";

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ThemeData themeData;

  List<HomeScreenComponentModel> components = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Container(
      color: themeData.colorScheme.background,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
        ),
      ),
    );
  }
}
