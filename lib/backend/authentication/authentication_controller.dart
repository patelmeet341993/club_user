import 'package:club_model/club_model.dart';
import 'package:club_user/backend/authentication/authentication_repository.dart';
import 'package:club_user/backend/navigation/navigation_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'authentication_provider.dart';

class AuthenticationController {
  late AuthenticationProvider _authenticationProvider;
  late AuthenticationRepository _authenticationRepository;

  AuthenticationController({
    required AuthenticationProvider? authenticationProvider,
    AuthenticationRepository? repository,
  }) {
    _authenticationProvider = authenticationProvider ?? AuthenticationProvider();
    _authenticationRepository = repository ?? AuthenticationRepository();
  }

  AuthenticationProvider  get authenticationProvider => _authenticationProvider;
  AuthenticationRepository  get authenticationRepository => _authenticationRepository;

  Future<bool> isUserLoggedIn() async {
    AuthenticationProvider provider = authenticationProvider;

    User? firebaseUser = await FirebaseAuth.instance.authStateChanges().first;

    if(firebaseUser == null) {
      if(kIsWeb) {
        await Future.delayed(const Duration(seconds: 2));
        firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
      }
    }

    if(firebaseUser != null && (firebaseUser.phoneNumber ?? "").isNotEmpty) {
      provider.setAuthenticationDataFromFirebaseUser(
        firebaseUser: firebaseUser,
        isNotify: false,
      );
      return true;
    }
    else {
      logout();
      return false;
    }
  }

  Future<bool> logout({bool isNavigateToLogin = false}) async {
    BuildContext? context = NavigationController.mainScreenNavigator.currentContext;

    bool isLoggedOut = false;

    AuthenticationProvider provider = authenticationProvider;
    provider.resetData(isNotify: false);

    try {
      Future.wait([
        FirebaseAuth.instance.signOut().then((value) {
          MyPrint.printOnConsole("Logged Out User From Firebase Auth");
        })
            .catchError((e, s) {
          MyPrint.printOnConsole("Error in Logging Out User From Firebase:$e");
          MyPrint.printOnConsole(s);
        }),
      ]);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Logging Out:$e");
      MyPrint.printOnConsole(s);
    }

    isLoggedOut = true;

    if(isNavigateToLogin && context != null) {
      NavigationController.navigateToLoginScreen(navigationOperationParameters: NavigationOperationParameters(
        context: context,
        navigationType: NavigationType.pushNamedAndRemoveUntil,
      ));
    }

    return isLoggedOut;
  }
}
