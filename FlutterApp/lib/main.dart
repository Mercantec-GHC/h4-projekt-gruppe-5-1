import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:sks_booking/api.dart';
import 'package:provider/provider.dart';
import 'package:sks_booking/pages/renter_homepage.dart';

import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/update_user.dart';
import 'pages/get_rentals_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'SKS Booking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(198, 48, 48, 48)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final ApiService apiService =
      ApiService(baseUrl: 'https://localhost:7014/api');
  var current = WordPair.random();
  var backgroundColor = Color.fromARGB(198, 48, 48, 48);

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void changeBackgroundColor(Color color) {
    backgroundColor = color;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      var response = await apiService.loginUser(email, password);
      if (response.id != 0) {
        storage.write(key: 'token', value: response.token);
      }
    } catch (e) {
      print('login failed: $e');
    }
  }

  Future<void> register(String name, String email, String password,
      String phoneNumber, String username) async {
    try {
      var response = await apiService.createUser(
          name, email, password, phoneNumber, username);
      if (response.containsKey('id')) {
        print('User created with ID: ${response['id']}');
      }
    } catch (e) {
      print('Registration failed: $e');
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  void switchToRegisterPage() {
    setState(() {
      selectedIndex = 1;
    });
  }

  void switchToLoginPage() {
    setState(() {
      selectedIndex = 0;
    });
  }

  // skal gjøres om til en Drawer. Det er måten vi kan få en "Burgerbar". Så må jeg bare finne ut hvordan jeg får den over på høyre side.

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = LoginPage(onCreateUser: switchToRegisterPage);
        break;
      case 1:
        page = RegisterPage(onLogin: switchToLoginPage);
        break;
      case 2:
        page = GetRentalsPage();
        break;
      case 3:
        page = UpdatePage();
        break;
      case 4:
        page = RenterHomepage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.login),
                  label: Text('Login'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.create),
                  label: Text('Create User'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Get Rentals'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.update),
                  label: Text('Update'),
                ),
                NavigationRailDestination(
                    icon: Icon(Icons.home), label: Text('Homepage')),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: appState.backgroundColor,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}
