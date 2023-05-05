import 'package:club_model/club_model.dart';
import 'package:club_model/models/user/data_model/user_model.dart';

class AuthenticationProvider extends CommonProvider {
  AuthenticationProvider() {
    firebaseUser = CommonProviderPrimitiveParameter<User?>(
      value: null,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
    mobileNumber = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
    userModel = CommonProviderPrimitiveParameter<UserModel?>(
      value: null,
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<User?> firebaseUser;
  late CommonProviderPrimitiveParameter<String> userId;
  late CommonProviderPrimitiveParameter<String> mobileNumber;
  late CommonProviderPrimitiveParameter<UserModel?> userModel;

  void setAuthenticationDataFromFirebaseUser({
    User? firebaseUser,
    bool isNotify = true,
  }) {
    this.firebaseUser.set(value: firebaseUser, isNotify: false);
    userId.set(value: firebaseUser?.uid ?? "", isNotify: false);
    mobileNumber.set(value: firebaseUser?.phoneNumber ?? "", isNotify: isNotify);
  }

  void resetData({bool isNotify = true}) {
    firebaseUser.set(value: null, isNotify: false);
    userId.set(value: "", isNotify: false);
    mobileNumber.set(value: "", isNotify: isNotify);
    userModel.set(value: null, isNotify: isNotify);
  }
}