import 'package:club_model/backend/common/common_provider.dart';

class HomeScreenProvider extends CommonProvider {
  HomeScreenProvider() {
    homeTabIndex = CommonProviderPrimitiveParameter<int>(
      value: 0,
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<int> homeTabIndex;
}