import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Import the necessary library
import 'dart:convert';
import 'package:geddit/request_errands.dart';

import 'firebase_options.dart';
import 'listed_errands.dart';
import 'my_errands.dart';
import 'authentication.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String user = '';

void main() async {
  // ignore: unused_local_variable
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.subscribeToTopic("all");
  final notificationSettings =
      await FirebaseMessaging.instance.requestPermission(provisional: true);

// For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
  }

  runApp(MyApp(home: (await autoLogin()) ? MyHomePage() : LoginPage()));

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  var home;
  MyApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.lightBlueAccent,
        primaryColor: Colors.black,
        textTheme: const TextTheme(
          headline1: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headline2: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyText1: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          button: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      home: home,
    );
  }
}

// Additional methods or widgets for handling login logic can be added here

// ###################################################################################################################################

class ErrandModel {
  final String from;
  final String to;
  final int price;

  ErrandModel({required this.from, required this.to, required this.price});
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: const [
            MyErrandsScreen(),
            ListedErrandsScreen(),
            RequestErrandsScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPage,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run),
              label: 'My Errands',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Listed Errands',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Request Errands',
            ),
          ],
          backgroundColor: Colors.green,
          selectedItemColor: Colors.brown,
          unselectedItemColor: Colors.greenAccent,
        ),
      ),
    );
  }
}
