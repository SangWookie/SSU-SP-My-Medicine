import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medicineapp/screens/login_screen.dart';
import 'package:medicineapp/screens/presc_list_screen.dart';
import 'package:medicineapp/screens/presc_upload_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:medicineapp/screens/userinfo_screen.dart';
import 'dart:developer' as developer;

class HomeScreen extends StatelessWidget {
  final int uid;
  final Function func;
  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();

  HomeScreen({
    Key? key,
    required this.uid,
    required this.func,
  }) : super(key: key);

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  void setIndex(int index, BuildContext context) {
    developer.log("newscreen");
    _homeNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          uid: uid,
          func: func,
        ),
      ),
      (route) => false,
    );
  }

  void pushExitScreen(BuildContext context) {
    developer.log("Exit");
    _homeNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          func: func,
        ),
      ),
      (route) => false,
    );
  }

  // void pushUploadScreen(BuildContext context) {
  //   Navigator.of(context).push(MaterialPageRoute(
  //     builder: (context) {
  //       return PrescListScreen(
  //         uid: uid,
  //         func: func,
  //       );
  //     },
  //   ));
  // }
  void pushUploadScreen(BuildContext context) {
    developer.log("uploadscreen");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescUploadScreen(
          uid: uid,
          func: func,
        ),
      ),
    );
  }

  void pushUserInfoScreen(BuildContext context) {
    developer.log("infoscreen");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(
          uid: uid,
          func: func,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("앱 종료"),
              content: Text("앱을 종료하시겠습니까?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    Navigator.of(context).maybePop();
                  },
                  child: Text("종료"),
                ),
              ],
            );
          },
        );
      },
      child: Navigator(
        key: _homeNavigatorKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => PersistentTabView(
              context,
              controller: _controller,
              screens: _buildScreens(
                uid,
                pushExitScreen,
                pushUploadScreen,
                pushUserInfoScreen,
              ),
              items: _navBarsItems(
                  context, uid, pushUploadScreen, pushUserInfoScreen),
              confineInSafeArea: true,
              backgroundColor: Colors.white,
              handleAndroidBackButtonPress: true,
              resizeToAvoidBottomInset: true,
              stateManagement: true,
              hideNavigationBarWhenKeyboardShows: true,
              decoration: NavBarDecoration(
                borderRadius: BorderRadius.circular(10.0),
                colorBehindNavBar: Colors.white,
              ),
              popAllScreensOnTapOfSelectedTab: true,
              popActionScreens: PopActionScreensType.all,
              itemAnimationProperties: const ItemAnimationProperties(
                duration: Duration(milliseconds: 200),
                curve: Curves.ease,
              ),
              screenTransitionAnimation: const ScreenTransitionAnimation(
                animateTabTransition: true,
                curve: Curves.ease,
                duration: Duration(milliseconds: 200),
              ),
              navBarStyle: NavBarStyle.style15,
            ),
          );
        },
      ),
    );
  }
}

List<Widget> _buildScreens(int uid, Function pushExitScreen,
    Function pushUploadScreen, Function pushUserInfoScreen) {
  return [
    PrescListScreen(
      key: UniqueKey(), // UniqueKey 추가
      uid: uid,
      func: pushExitScreen,
    ), // Home
    PrescUploadScreen(
      uid: uid,
      func: pushUploadScreen,
    ), // Add
    UserInfoScreen(
      key: UniqueKey(), // UniqueKey 추가
      uid: uid,
      func: pushUserInfoScreen,
    ), // My Page
  ];
}

List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context, int uid,
    Function pushUploadScreen, Function pushUserInfoScreen) {
  return [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.home),
      title: ("Home"),
      activeColorPrimary: Colors.deepPurple[200]!,
      inactiveColorPrimary: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.add),
      title: ("Add"),
      activeColorPrimary: Colors.deepPurple[200]!,
      activeColorSecondary: Colors.white,
      inactiveColorPrimary: Colors.grey,
      inactiveColorSecondary: Colors.grey,
      // onPressed: (context) {
      //   developer.log("Context value: $context");

      //   Navigator.push(
      //     context!,
      //     MaterialPageRoute(
      //       builder: (context) => PrescUploadScreen(
      //         uid: uid,
      //         func: pushUploadScreen,
      //       ),
      //     ),
      //   );
      // },
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.account_circle),
      title: ("My Page"),
      activeColorPrimary: Colors.deepPurple[200]!,
      inactiveColorPrimary: Colors.grey,
      // onPressed: (context) {
      //   developer.log("Context value: $context");

      //   Navigator.push(
      //     context!,
      //     MaterialPageRoute(
      //       builder: (context) => UserInfoScreen(
      //         uid: uid,
      //         func: pushUserInfoScreen,
      //       ),
      //     ),
      //   );
      // },
    ),
  ];
}
