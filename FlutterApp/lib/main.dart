import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_input/image_input.dart';
import 'package:sks_booking/api.dart';
import 'package:provider/provider.dart';
import 'package:sks_booking/pages/admin_homepage.dart';
import 'package:sks_booking/pages/rental_homepage.dart';
import 'package:sks_booking/pages/password_change.dart';
import 'package:sks_booking/pages/renter_homepage.dart';
import 'package:sks_booking/pages/update_biography.dart';
import 'api.dart' as api;
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/update_user.dart';
import 'pages/get_rentals_page.dart';
import 'pages/account_update.dart';

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
            seedColor: Color(0xFFCAC3A5),
            brightness: Brightness.light,
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final ApiService apiService = ApiService(baseUrl: 'https://localhost:7014/api');
  late var success = false;

  Future<void> login(String email, String password) async {
    try {
      await apiService.loginUser(email, password);
      notifyListeners();
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

  Future<void> updateUser(String name, XFile? img, String? oldImg) async {
    try {
      var response = await apiService.updateUser(name, img, oldImg);
      return jsonDecode(response);
    } catch (e) {
      print('Noget: $e');
    }
  }

  Future<void> updateUserBio(String bio) async {
    try {
      var response = await apiService.updateUserBio(bio);
      return jsonDecode(response);
    } catch (e) {
      print('Noget: $e');
    }
  }

  Future<void> updateUserAccount(
      String username, String email, String phoneNumber) async {
    try {
      await apiService.updateAccount(email, username, phoneNumber);
    } catch (e) {
      print('Noget: $e');
    }
  }

  Future<void> updateUserPassword(String password, String oldPassword) async {
    try {
      await apiService.updatePassword(password, oldPassword);
    } catch (e) {
      print('Noget: $e');
    }
  }

  void logOut() async {
    await apiService.logoutUser();
    notifyListeners();
  }

  Future<Map<String, dynamic>> user() async {
    var user = await apiService.getUser();
    return user;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  String? userName;

  @override
  void initState() {
    super.initState();

    // Hent brugerdata og sæt navn i drawer-menuen
    _loadUserData();
  }

  void _loadUserData() async {
    final myAppState = Provider.of<MyAppState>(context, listen: false);

    try {
      // Hent brugerdata
      var userData = await myAppState.user();

      setState(() {
        // Sæt brugernavn i userName
        userName = userData['username'] ??
            'Bruger'; // Fallback til 'Bruger', hvis name er null
      });
    } catch (e) {
      print('Fejl ved hentning af brugerdata: $e');
    }
  }

  void switchToRegisterPage() {
    setState(() {
      selectedIndex = 1;
    });
  }
  void switchToBioUpdatePage() {
    setState(() {
      selectedIndex = 5;
    });
  }

  void switchToUserUpdatePage() {
    setState(() {
      selectedIndex = 1;
    });
  }

  void switchToLoginPage() {
    setState(() {
      selectedIndex = 0;
    });
  }

  void switchToChangePassword() {
    setState(() {
      selectedIndex = 4;
    });
  }

  void switchToUpdateAccount() {
    setState(() {
      selectedIndex = 2;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final myAppState = Provider.of<MyAppState>(context);
    bool isLoggedIn = api.loggedIn;

    List<Widget> nav;
    List<Widget> page;

    if (isLoggedIn) {
      nav = [
        DrawerHeader(
          child: Text(
              userName != null ? 'Velkommen, $userName' : 'Velkommen, Bruger'),
        ),
        ListTile(
          leading: Icon(Icons.apartment),
          title: Text('Alle lejligheder'),
          selected: selectedIndex == 0,
          onTap: () {
            _onItemTapped(0);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Profil'),
          selected: selectedIndex == 1,
          onTap: () {
            _onItemTapped(1);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('konto'),
          selected: selectedIndex == 2,
          onTap: () {
            _onItemTapped(2);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Hjem'),
          selected: selectedIndex == 3,
          onTap: () {
            _onItemTapped(3);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Hjem Udlejer'),
          selected: selectedIndex == 4,
          onTap: () {
            _onItemTapped(4);
            Navigator.pop(context);
          },
        ),
      ];
      page = [
        GetRentalsPage(),
        UpdatePage(userData: myAppState.user(), onBio: switchToBioUpdatePage),
        AccountUpdater(onPassword: switchToChangePassword, userData: myAppState.user()),
        RenterHomepage(),
        RentalHomepage(),
        PasswordChanger(onUpdate: switchToUpdateAccount),
        BiographyUpdater(onUser: switchToUserUpdatePage, userData: myAppState.user())
      ];
    } else {
      nav = [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Color(0xFFCAC3A5),
          ),
          child: Text(style: TextStyle(fontSize: 40), 'Velkommen'),
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
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Rental'),
          selected: selectedIndex == 4,
          onTap: () {
            _onItemTapped(4);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Admin'),
          selected: selectedIndex == 5,
          onTap: () {
            _onItemTapped(5);
            Navigator.pop(context);
          },
        ),
      ];
      page = [
        LoginPage(onCreateUser: switchToRegisterPage),
        RegisterPage(onLogin: switchToLoginPage),
        GetRentalsPage(),
        RenterHomepage(),
        AdminHomepage(),
      ];
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFCAC3A5),
        titleTextStyle: TextStyle(fontSize: 40),
        centerTitle: true,
        title: Text('SKS Booking'),
      ),
      endDrawer: Drawer(
        elevation: 20.0,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: nav,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () {
                  if (isLoggedIn) {
                    myAppState.logOut();
                  } else {
                    setState(() {
                      selectedIndex = 0;
                    });
                  }
                  _onItemTapped(0);
                  Navigator.pop(context);
                },
                child: Icon(isLoggedIn ? Icons.logout : Icons.login),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF1EFE7),
      body: Center(
        child: page[selectedIndex],
      ),
    );
  }
}
