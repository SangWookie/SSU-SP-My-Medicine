import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medicineapp/screens/home_screen.dart';
import 'package:medicineapp/screens/login_screen.dart';

class MyImageCache extends ImageCache {
  @override
  void clear() {
    // print('Clearing cache!');
    super.clear();
  }
}

class MyWidgetsBinding extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() => MyImageCache();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  HttpOverrides.global = MyHttpOverrides();
  MyWidgetsBinding();

  runApp(const MyApp());
}

void asd() {
  Function func;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // final Function func;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine App',
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(primarySwatch: Colors.deepPurple, fontFamily: "NotoSansKR"),
      home: LoginScreen(
        func: asd,
      ),
      // home: const TempWidget(),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36';
  }
}

class TempWidget extends StatelessWidget {
  const TempWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
