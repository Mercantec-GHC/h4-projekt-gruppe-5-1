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
import 'package:shared_preferences/shared_preferences.dart';
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
  final ApiService apiService =
      ApiService(baseUrl: 'https://localhost:7014/api');
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
      String phoneNumber, String username, int userType) async {
    try {
      var response = await apiService.createUser(
          name, email, password, phoneNumber, username, userType);
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
      return response;
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
  String? userType;
  String? userName;

  @override
  void initState() {
    super.initState();
    ryd();
    _loadUserData();
  }

  void ryd() async {
    final prefs = await SharedPreferences.getInstance();
    var keys = [
      'id',
      'token',
      'userType',
      'name',
      'userName',
      'email',
      'phoneNumber',
      'id',
      'biography',
      'profilePictureURL'
    ];
    Future<void> reset() async {
      for (var element in keys) {
        await apiTing().apiService.secureStorage.delete(key: element);
      }
      apiTing().logOut();
      print('test 2');
    }

    //reset();

    if (prefs.getBool('first_run') ?? true) {
      print('test');
      reset();
      prefs.setBool('first_run', false);
    }
    if (prefs.getBool('restart') ?? true) {
      print('test 3');
      reset();
      prefs.setBool('restart', false);
    }
  }

  MyAppState apiTing() {
    final myAppState = Provider.of<MyAppState>(context, listen: false);
    return myAppState;
  }

  void _loadUserData() async {
    try {
      // Hent brugerdata
      var userData = await apiTing().user();
      print(userData);
      setState(() {
        // Sæt brugernavn i userName
        userType = userData['userType'] ?? '0';
        userName = userData['username'] ??
            'Bruger'; // Fallback til 'Bruger', hvis name er null
      });
    } catch (e) {
      print('Fejl ved hentning af brugerdata: $e');
    }
  }

  void switchToRegisterPage() {
    setState(() {
      selectedIndex = 2;
    });
  }

  void switchToBioUpdatePage() {
    setState(() {
      selectedIndex = 5;
    });
  }

  void switchToUserUpdatePage() {
    setState(() {
      selectedIndex = 2;
    });
  }

  void switchToLoginPage() {
    setState(() {
      selectedIndex = 1;
    });
  }

  void switchToChangePassword() {
    setState(() {
      selectedIndex = 4;
    });
  }

  void switchToUpdateAccount() {
    setState(() {
      selectedIndex = 3;
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
        ), //0
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Hjem'),
          selected: selectedIndex == 0,
          onTap: () {
            _onItemTapped(0);
            Navigator.pop(context);
          },
        ), //1
        ListTile(
          leading: Icon(Icons.apartment),
          title: Text('Alle lejligheder'),
          selected: selectedIndex == 1,
          onTap: () {
            _onItemTapped(1);
            Navigator.pop(context);
          },
        ), //2
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Profil'),
          selected: selectedIndex == 2,
          onTap: () {
            _onItemTapped(2);
            Navigator.pop(context);
          },
        ), //3
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('konto'),
          selected: selectedIndex == 3,
          onTap: () {
            _onItemTapped(3);
            Navigator.pop(context);
          },
        ), //4
      ];
      page = [
        RenterHomepage(), //0
        GetRentalsPage(), //1
        UpdatePage(
            userData: myAppState.user(), onBio: switchToBioUpdatePage), //2
        AccountUpdater(
            onPassword: switchToChangePassword,
            userData: myAppState.user()), //3
        PasswordChanger(onUpdate: switchToUpdateAccount), //4
        BiographyUpdater(
            onUser: switchToUserUpdatePage, userData: myAppState.user()), //5
      ];
      if (userType == "1") {
        page[0] = RentalHomepage();
        nav[1] = ListTile(
          leading: Icon(Icons.home),
          title: Text('Hjem udlejer'),
          selected: selectedIndex == 0,
          onTap: () {
            _onItemTapped(0);
            Navigator.pop(context);
          },
        );
      } else if (userType == "2") {
        page[0] = AdminHomepage();
        nav[1] = ListTile(
          leading: Icon(Icons.home),
          title: Text('Admin'),
          selected: selectedIndex == 0,
          onTap: () {
            _onItemTapped(0);
            Navigator.pop(context);
          },
        );
      }
    } else {
      nav = [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Color(0xFFCAC3A5),
          ),
          child: Text(style: TextStyle(fontSize: 40), 'Velkommen'),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Hjem'),
          selected: selectedIndex == 0,
          onTap: () {
            _onItemTapped(0);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.login),
          title: Text('Login'),
          selected: selectedIndex == 1,
          onTap: () {
            _onItemTapped(1);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.create),
          title: Text('Ny bruger'),
          selected: selectedIndex == 2,
          onTap: () {
            _onItemTapped(2);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.apartment),
          title: Text('Alle lejligheder'),
          selected: selectedIndex == 3,
          onTap: () {
            _onItemTapped(3);
            Navigator.pop(context);
          },
        ),
      ];
      page = [
        RenterHomepage(),
        LoginPage(onCreateUser: switchToRegisterPage),
        RegisterPage(onLogin: switchToLoginPage),
        GetRentalsPage(),
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
                    _onItemTapped(0);
                  } else {
                    setState(() {
                      selectedIndex = 1;
                    });
                    _onItemTapped(1);
                  }
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
