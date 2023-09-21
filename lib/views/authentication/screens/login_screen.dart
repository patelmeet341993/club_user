import 'package:club_model/club_model.dart';
import 'package:club_user/backend/navigation/navigation_arguments.dart';
import 'package:club_user/backend/navigation/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/LoginScreen";

  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with MySafeState {
  late ThemeData themeData;

  bool isFirst = true, isLoading = false;

  late TextEditingController mobileController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void sendOtp() {
    if (!context.read<ConnectionProvider>().isInternet) {
      MyToast.showError(msg: "No Internet", context: context);
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    _formKey.currentState!.save();

    String mobileNumber = mobileController.text.trim();

    // if all are valid then go to success screen
    if (context.checkMounted() && context.mounted) {
      NavigationController.navigateToOtpScreen(
        navigationOperationParameters: NavigationOperationParameters(
          context: context,
          navigationType: NavigationType.pushNamed,
        ),
        arguments: OtpScreenNavigationArguments(mobile: mobileNumber),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    mobileController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    if (isFirst) {
      isFirst = false;
      // AppUpdateController().checkAppVersion(context);
    }

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: themeData.colorScheme.background,
        body: Container(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          getLogo(),
                          getLoginText(),
                          getLoginText2(),
                          getMobileTextField(),
                          getContinueButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 34),
      width: 100,
      height: 100,
      child: Image.asset(
        "assets/logo2.png",
      ),
    );
  }

  Widget getLoginText() {
    return InkWell(
      onTap: () async {
        // bool result= await UserController().isUserLogin(context: context,isPromt: true);
        // MyPrint.printOnConsole("result : $result");
      },
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        child: Center(
          child: Text(
            "Log In",
            style: themeData.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoginText2() {
    return Container(
      margin: const EdgeInsets.only(left: 48, right: 48, top: 40),
      child: Text(
        "Enter your login details to access your account",
        softWrap: true,
        style: themeData.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: themeData.colorScheme.onBackground.withAlpha(200),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget getMobileTextField() {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 36),
      child: Container(
        decoration: BoxDecoration(
          color: themeData.cardTheme.color,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              blurRadius: 8.0,
              color: themeData.cardTheme.shadowColor!.withAlpha(25),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextFormField(
          controller: mobileController,
          style: themeData.textTheme.bodyLarge?.copyWith(
            letterSpacing: 0.1,
            color: themeData.colorScheme.onBackground,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Enter Mobile Number",
            prefixText: "+91 ",
            prefixStyle: themeData.textTheme.titleSmall?.copyWith(
              letterSpacing: 0.1,
              color: themeData.colorScheme.onBackground,
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: themeData.colorScheme.onBackground),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: themeData.colorScheme.onBackground),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: themeData.colorScheme.onBackground),
            ),
            filled: true,
            fillColor: themeData.colorScheme.background,
            prefixIcon: Icon(
              Icons.phone,
              size: 22,
              color: themeData.colorScheme.onBackground.withAlpha(200),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.all(0),
          ),
          keyboardType: TextInputType.number,
          autofocus: false,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (val) {
            if (val?.isEmpty ?? true) {
              return "Mobile Number Cannot be empty";
            } else {
              if (RegExp(r"^[0-9]{10}").hasMatch(val!)) {
                return null;
              } else {
                return "Invalid Mobile Number";
              }
            }
          },
        ),
      ),
    );
  }

  Widget getTermsAndConditionsLink() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        child: Center(
          child: Text(
            "Terms and Conditions",
            style: themeData.textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  Widget getContinueButton() {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 36),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(48)),
      ),
      child: MaterialButton(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: themeData.colorScheme.primary,
        highlightColor: themeData.colorScheme.primary,
        splashColor: Colors.white.withAlpha(100),
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        onPressed: sendOtp,
        child: Stack(
          //overflow: Overflow.visible,
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                "CONTINUE",
                style: themeData.textTheme.bodyMedium?.copyWith(
                  color: themeData.colorScheme.onPrimary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              right: 16,
              child: ClipOval(
                child: Container(
                  color: themeData.colorScheme.primary,
                  // button color
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(
                      Icons.arrow_forward,
                      color: themeData.colorScheme.onPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
