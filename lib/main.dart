import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nex_chat/Screens/LoginScreen.dart';
import 'package:nex_chat/Screens/Models/UserModel.dart';
import 'package:nex_chat/Screens/NavBarScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? u;
  bool? loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? data = sp.getString('user');
    if (data != null) {
      u = User.fromMap(jsonDecode(data));
    } else {
      u = null;
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? MaterialApp(home: Scaffold(body: CircularProgressIndicator()))
        : MaterialApp(
            title: 'Nex Chat',
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                iconTheme: const IconThemeData(
                  color: const Color.fromARGB(255, 163, 250, 166),
                  size: 20,
                ),
                color: Colors.white,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  color: const Color.fromARGB(255, 163, 250, 166),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: const Color.fromARGB(255, 163, 250, 166),
                unselectedItemColor: Colors.black,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 163, 250, 166),
                  foregroundColor: Colors.white,
                ),
              ),
              scaffoldBackgroundColor: Colors.grey[100],
            ),
            debugShowCheckedModeBanner: false,
            home: u != null ? Navbarscreen(user: u!) : Loginscreen(),
          );
  }
}
