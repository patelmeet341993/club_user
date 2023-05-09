import 'package:club_model/backend/navigation/navigation_arguments.dart';
import 'package:club_model/models/user/data_model/user_model.dart';

class OtpScreenNavigationArguments extends NavigationArguments {
  final String mobile;

  const OtpScreenNavigationArguments({
    required this.mobile,
  });
}

class EditProfileScreenNavigationArguments extends NavigationArguments {
  final UserModel userModel;

  const EditProfileScreenNavigationArguments({
    required this.userModel,
  });
}
