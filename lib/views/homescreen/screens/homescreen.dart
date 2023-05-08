import 'package:club_model/club_model.dart';
import 'package:club_user/views/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../../../backend/home_screen/home_screen_provider.dart';
import '../../common/models/home_screen_component_model.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/HomeScreen";

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, MySafeState {
  int _currentIndex = 0;
  late TabController _tabController;

  late HomeScreenProvider homeScreenProvider;

  List<HomeScreenComponentModel> components = [];

  Widget? homeWidget, favouriteWidget,profileWidget,wallpaperListWidget;

  //region Tab Handling
  _handleTabSelection() {
    FocusScope.of(context).requestFocus(FocusNode());

    MyPrint.printOnConsole("_handleTabSelection called");
    _currentIndex = _tabController.index;
    homeScreenProvider.homeTabIndex.set(value: _tabController.index, isNotify: true);

    //if(_currentIndex == 1 && Provider.of<ProductProvider>(context, listen: false).searchedProductsList == null) ProductController().getProducts(context, true, withnotifying: false);
  }

  _handleTabSelectionInAnimation() {
    final aniValue = _tabController.animation?.value ?? 0;
    //MyPrint.printOnConsole("Animation Value:$aniValue");
    //MyPrint.printOnConsole("Current Value:$_currentIndex");

    double diff = aniValue - _currentIndex;

    //MyPrint.printOnConsole("Current Before:$_currentIndex");
    if (aniValue - _currentIndex > 0.5) _currentIndex++;
    else if (aniValue - _currentIndex < -0.5) _currentIndex--;
    //MyPrint.printOnConsole("Current After:$_currentIndex");

    //if(_currentIndex == 1 && Provider.of<ProductProvider>(context, listen: false).searchedProductsList == null) ProductController().getProducts(context, true, withnotifying: false);

    //For Direct Tap
    if(diff != 1 && diff != -1 && diff != 2 && diff != -2 && diff != 3 && diff != -3) {
      mySetState();
    }

  }
  //endregion

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this,initialIndex: 0);
    _tabController.addListener(_handleTabSelection);
    _tabController.animation?.addListener(_handleTabSelectionInAnimation);
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return Consumer(
      builder: (BuildContext context, HomeScreenProvider homeScreenProvider, Widget? child) {
        this.homeScreenProvider = homeScreenProvider;

        return Container(
          color: themeData.colorScheme.background,
          child: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              bottomNavigationBar: getBottomBar(homeScreenProvider),
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  getBottlesListScreen(),
                  getMyBottlesListScreen(),
                  getClubsListScreen(),
                  getUserProfile()
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //region Bottom Navigation Section
  Widget getBottomBar(HomeScreenProvider homeScreenProvider) {
    return Container(
      decoration: BoxDecoration(
        //color: themeData.bottomAppBarTheme.color,
        //borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        //border: Border.symmetric(horizontal: BorderSide(color: themeData.colorScheme.primary, width: 0.8,)),
        boxShadow: [
          BoxShadow(
            color: themeData.cardTheme.shadowColor!.withAlpha(40),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        //color: Color(0xff292929),
        shape: const CircularNotchedRectangle(),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        notchMargin: 5,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: themeData.bottomAppBarTheme.color,
            //borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            //border: Border.symmetric(horizontal: BorderSide(color: themeData.colorScheme.primary, width: 0.8,)),
            boxShadow: [
              BoxShadow(
                color: themeData.cardTheme.shadowColor!.withAlpha(40),
                blurRadius: 3,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: TabBar(
            onTap: (int index) {

            },
            controller: _tabController,
            indicator: const BoxDecoration(),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: themeData.colorScheme.onBackground,
            labelColor: themeData.colorScheme.onBackground,
            unselectedLabelColor: themeData.colorScheme.onBackground.withOpacity(0.4),
            labelPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            labelStyle: (themeData.textTheme.bodySmall ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            tabs: const <Widget>[
              Tab(
                icon: Icon(MdiIcons.home, size: 20,),
                iconMargin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                text: "Bottles",
              ),
              Tab(
                icon: Icon(MdiIcons.magnify, size: 20,),
                iconMargin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                text: "My Bottles",
              ),
              Tab(
                icon: Icon(MdiIcons.heartOutline, size: 20,),
                iconMargin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                text: "Clubs",
              ),
              Tab(
                icon: Icon(MdiIcons.account, size: 20,),
                iconMargin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                text: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBottomBarButton({String? text, required int index, required IconData iconData}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(iconData, size: 20, color: themeData.colorScheme.primary,),
        index != _currentIndex
            ? Text(
          text ?? "",
          style: themeData.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: themeData.colorScheme.primary,
          ),
        )
            : const SizedBox.shrink(),
      ],
    );
  }
  //endregion

  Widget getBottlesListScreen() {
    homeWidget ??= const Center(
      child: Text("Bottles List Screen"),
    );

    return homeWidget!;
  }

  Widget getMyBottlesListScreen() {
    wallpaperListWidget ??= const Center(
      child: Text("My Bottles List Screen"),
    );

    return wallpaperListWidget!;
  }

  Widget getClubsListScreen() {
    favouriteWidget ??= const Center(
      child: Text("Clubs List Screen"),
    );

    return favouriteWidget!;
  }

  Widget getUserProfile() {
    profileWidget ??= const ProfileScreen();

    return profileWidget!;
  }
}
