import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:sks_booking/api.dart';
import 'package:provider/provider.dart';
import 'package:sks_booking/pages/renter_homepage.dart';
import 'api.dart' as api;
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

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = api.loggedIn;
    List<Widget> nav;
    List<Widget> page;

    if (isLoggedIn) {
      nav = [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Noget text her'),
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Drawer layout Item 1'),
          selected: selectedIndex == 0,
          onTap: () {
            _onItemTapped(0);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.accessibility),
          title: Text('Drawer layout Item 2'),
          selected: selectedIndex == 1,
          onTap: () {
            _onItemTapped(1);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.account_box),
          title: Text('Drawer layout Item 3'),
          selected: selectedIndex == 2,
          onTap: () {
            _onItemTapped(2);
            Navigator.pop(context);
          },
        )
      ];
      page = [
        GetRentalsPage(),
        UpdatePage(),
        RenterHomepage(),
      ];
    } else {
      nav = [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
              style: TextStyle(color: Colors.white, fontSize: 40),
              'Noget text her'),
        ),
        ListTile(
          leading: Icon(Icons.login),
          title: Text('Login'),
          selected: selectedIndex == 0,
          onTap: () {
            _onItemTapped(0);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.create),
          title: Text('New user'),
          selected: selectedIndex == 1,
          onTap: () {
            _onItemTapped(1);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.apartment),
          title: Text('All apartments'),
          selected: selectedIndex == 2,
          onTap: () {
            _onItemTapped(2);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          selected: selectedIndex == 3,
          onTap: () {
            _onItemTapped(3);
            Navigator.pop(context);
          },
        )
      ];
      page = [
        LoginPage(onCreateUser: switchToRegisterPage),
        RegisterPage(onLogin: switchToLoginPage),
        GetRentalsPage(),
        RenterHomepage(),
      ];
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 40),
        centerTitle: true,
        title: Text('SKS Booking'),
      ),
      endDrawer: Drawer(
          elevation: 20.0,
          child: ListView(
            padding: EdgeInsets.zero,
            children: nav,
          )),
      body: Center(
        child: page[selectedIndex],
      ),
    );
  }
}
