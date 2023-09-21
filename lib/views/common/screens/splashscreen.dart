
import 'package:club_model/club_model.dart';
import 'package:club_user/backend/authentication/authentication_controller.dart';
import 'package:club_user/backend/authentication/authentication_provider.dart';
import 'package:flutter/material.dart';

import '../../../backend/navigation/navigation_controller.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/SplashScreen";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late ThemeData themeData;

  Future<void> checkLogin() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("SplashScreen().checkLogin() called", tag: tag);

    NavigationController.isFirst = false;

    AuthenticationProvider authenticationProvider = context.read<AuthenticationProvider>();
    AuthenticationController authenticationController = AuthenticationController(authenticationProvider: authenticationProvider);

    await Future.delayed(const Duration(seconds: 3));

    /*authenticationController.logout(isNavigateToLogin: true);
    return;*/

    bool isUserLoggedIn = await authenticationController.isUserLoggedIn();
    MyPrint.printOnConsole("isUserLoggedIn:$isUserLoggedIn", tag: tag);

    if(isUserLoggedIn) {
      bool isExist = await authenticationController.checkUserWithIdExistOrNotAndIfNotExistThenCreate(userId: authenticationProvider.userId.get());
      MyPrint.printOnConsole("isExist:$isExist", tag: tag);

      if(context.checkMounted() && context.mounted) {
        NavigationController.navigateToHomeScreen(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ),
        );
      }
    }
    else {
      if(context.checkMounted() && context.mounted) {
        NavigationController.navigateToLoginScreen(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Container(
      color: themeData.colorScheme.background,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: Column(
            children: [
              /*Center(
                child: LoadingAnimationWidget.inkDrop(color: themeData.backgroundColor, size: 40),
              ),*/
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(5)),
                      child: Icon(Icons.water, color: themeData.primaryColor, size: 80),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Club App",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Center(
                child: LoadingAnimationWidget.inkDrop(color: themeData.primaryColor, size: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
