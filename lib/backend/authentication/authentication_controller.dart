import 'package:club_model/backend/user/user_controller.dart';
import 'package:club_model/club_model.dart';
import 'package:club_user/backend/authentication/authentication_repository.dart';
import 'package:club_user/backend/navigation/navigation_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../views/common/components/MyCupertinoAlertDialogWidget.dart';
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

  Future<bool> checkUserWithIdExistOrNotAndIfNotExistThenCreate({
    required String userId,
  }) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AuthenticationController().checkUserWithIdExistOrNotAndIfNotExistThenCreate() called with userId:'$userId'", tag: tag);

    bool isUserExist = false;

    if(userId.isEmpty) return isUserExist;

    UserController userController = UserController();

    try {
      UserModel? userModel = await userController.userRepository.getUserModelFromId(userId: userId);
      MyPrint.printOnConsole("userModel:'$userModel'", tag: tag);

      if(userModel != null) {
        isUserExist = true;

        authenticationProvider.userModel.set(value: userModel, isNotify: false);
      }
      else {
        UserModel createdUserModel = UserModel(
          id: userId,
          mobileNumber: authenticationProvider.mobileNumber.get(),
        );
        bool isCreated = await userController.createNewUser(userModel: createdUserModel);
        MyPrint.printOnConsole("isUserCreated:'$isCreated'", tag: tag);

        if(isCreated) {
          authenticationProvider.userModel.set(value: createdUserModel, isNotify: false);
        }
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in AuthenticationController().checkUserWithIdExistOrNotAndIfNotExistThenCreate():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return isUserExist;
  }

  Future<bool> logout({bool isShowConfirmationDialog = false, bool isNavigateToLogin = false}) async {
    BuildContext? context = NavigationController.mainScreenNavigator.currentContext;

    bool? isLoggedOut;
    if(context != null && isShowConfirmationDialog) {
      isLoggedOut = await showDialog(
          context: context,
          builder: (context) {
            return MyCupertinoAlertDialogWidget(
              title: "Logout",
              description: "Are you sure want to logout?",
              neagtiveText: "No",
              positiveText: "Yes",
              negativeCallback: () => Navigator.pop(context, false),
              positiviCallback: () async {
                Navigator.pop(context, true);
              },
            );
          }
      );
    }
    else {
      isLoggedOut = true;
    }
    MyPrint.printOnConsole("IsLoggedOut:$isLoggedOut");

    if(isLoggedOut != true) {
      return false;
    }

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

    if(isNavigateToLogin && context != null && context.checkMounted() && context.mounted) {
      NavigationController.navigateToLoginScreen(navigationOperationParameters: NavigationOperationParameters(
        context: context,
        navigationType: NavigationType.pushNamedAndRemoveUntil,
      ));
    }

    return isLoggedOut;
  }
}
