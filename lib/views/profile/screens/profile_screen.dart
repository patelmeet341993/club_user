import 'package:club_model/club_model.dart';
import 'package:club_user/backend/navigation/navigation_arguments.dart';
import 'package:club_user/backend/navigation/navigation_controller.dart';
import 'package:flutter/material.dart';

import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/authentication/authentication_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with MySafeState {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return Consumer<AuthenticationProvider>(
      builder: (BuildContext context, AuthenticationProvider authenticationProvider, Widget? child) {
        UserModel? userModel = authenticationProvider.userModel.get();

        return SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: isLoading,
            progressIndicator: SpinKitFadingCircle(
              color: themeData.colorScheme.primary,
            ),
            child: Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(24),
                children: <Widget>[
                  getProfileDetails(userModel),
                  Column(
                    children: <Widget>[
                      /*singleOption(
                        isLogin: userProvider.userModel == null,
                        iconData: MdiIcons.accountEdit,
                        option: "Edit Profile",
                        screen: RouteNames.updateAndRegisterUser,
                      ),*/
                      singleOption1(
                        iconData: Icons.edit,
                        option: "Edit Profile",
                        ontap: () async {
                          if (userModel != null) {
                            await NavigationController.navigateToEditProfileScreen(
                              navigationOperationParameters: NavigationOperationParameters(
                                context: context,
                                navigationType: NavigationType.pushNamed,
                              ),
                              arguments: EditProfileScreenNavigationArguments(userModel: userModel),
                            );

                            mySetState();
                          }
                        },
                      ),
                      userModel != null
                          ? singleOption1(
                              iconData: Icons.logout,
                              option: "Logout",
                              ontap: () async {
                                MyPrint.printOnConsole("logout");
                                isLoading = true;
                                mySetState();

                                await AuthenticationController(authenticationProvider: authenticationProvider).logout(isShowConfirmationDialog: true, isNavigateToLogin: true);
                                MyPrint.printOnConsole("Logged Out");

                                isLoading = false;
                                mySetState();
                              },
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getProfileDetails(UserModel? userModel) {
    String userAccountDetails = "";
    if ((userModel?.mobileNumber ?? "").isNotEmpty) {
      userAccountDetails = (userModel?.mobileNumber ?? "");
    }

    ImageProvider<Object> image;
    if((userModel?.imageUrl ?? "").isNotEmpty) {
      image = CachedNetworkImageProvider(
        userModel!.imageUrl,
      );
    }
    else {
      image = const AssetImage("./assets/logo2.png");
    }

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        children: <Widget>[
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              //border: new Border.all(color: themeData.colorScheme.primary,),
            ),
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                image: image,
                fit: BoxFit.fill,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if(loadingProgress?.cumulativeBytesLoaded == loadingProgress?.expectedTotalBytes) {
                    return child;
                  }

                  return SpinKitCircle(color: themeData.primaryColor);
                },
              ),
            ),
          ),
          Visibility(
            visible: userAccountDetails.isNotEmpty,
            child: Column(
              children: [
                Text(
                  userModel?.name ?? "",
                  style: themeData.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  userAccountDetails,
                  style: themeData.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          //userModel != null ? SizedBox.shrink() : getLoginButton(),
        ],
      ),
    );
  }

  Widget singleOption({
    IconData? iconData,
    String? iconPath,
    required String option,
    String? screen,
    Object? argument,
    isLogin = false,
    double? imageIconSize,
    Function()? onTap,
  }) {
    return InkWell(
      onTap: () async {
        // AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.profile_menu_clicked, parameters: {AnalyticsParameters.event_value: option});
        /*if (isLogin) {
          bool result = await login();
          if (!result) return;
        }*/

        if (onTap != null) {
          onTap();
        }
        if (screen != null && screen.isNotEmpty) {
          Navigator.pushNamed(context, screen, arguments: argument);
        }
      },
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: themeData.colorScheme.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (iconData != null)
              Icon(
                iconData,
                size: 22,
                color: themeData.colorScheme.onBackground,
              ),
            if (iconPath != null && iconPath.isNotEmpty)
              Image.asset(
                iconPath,
                width: imageIconSize ?? 20,
                //color: themeData.colorScheme.onBackground,
              ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                child: Text(
                  option,
                  style: themeData.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 22,
              color: themeData.colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }

  Widget singleOption1({
    required IconData iconData,
    required String option,
    Function? ontap,
  }) {
    return InkWell(
      onTap: () async {
        if (ontap != null) ontap();

        // AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.profile_menu_clicked, parameters: {AnalyticsParameters.event_value: option});
      },
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: themeData.colorScheme.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 22,
              color: themeData.colorScheme.onBackground,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                child: Text(
                  option,
                  style: themeData.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 22,
              color: themeData.colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}
