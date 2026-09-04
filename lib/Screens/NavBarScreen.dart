import 'package:flutter/material.dart';
import 'package:nex_chat/Screens/HomeScreen.dart';
import 'package:nex_chat/Screens/LoginScreen.dart';
import 'package:nex_chat/Screens/addContactsScreen.dart';
import 'package:nex_chat/Screens/profileScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Models/UserModel.dart';

class Navbarscreen extends StatefulWidget {
  User user;

  Navbarscreen({required this.user});

  @override
  State<Navbarscreen> createState() => _NavbarscreenState();
}

class _NavbarscreenState extends State<Navbarscreen> {
  late List<Widget> _navBarScreens;
  int currentIndex = 0;

  void initState() {
    super.initState();

    _navBarScreens = [
      Homescreen(currentUser: widget.user),
      AddContactsScreen(currentUser: widget.user),
      Profilescreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.all(5.0),
            child: PopupMenuButton<String>(
              offset: Offset(0, 50),
              iconSize: 25,
              icon: Icon(
                Icons.more_vert,
                color: const Color.fromARGB(255, 163, 250, 166),
              ),
              onSelected: (value) async {
                if (value == 'logout') {
                  SharedPreferences sp = await SharedPreferences.getInstance();
                  sp.remove('user');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Loginscreen();
                      },
                    ),
                  );
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    height: 30,
                    value: 'logout',
                    textStyle: TextStyle(color: Colors.white),
                    child: Text('LogOut'),
                  ),
                ];
              },
            ),
          ),
        ],

        title: Row(
          spacing: 5,
          children: [
            Image.asset(
              "assets/images/icons8-chat-100.png",
              color: const Color.fromARGB(255, 163, 250, 166),
              height: 30,
              width: 30,
            ),
            Text('NexChat'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_page),
            label: 'Add contact',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (value) {
          currentIndex = value;
          setState(() {});
        },
      ),
      body: _navBarScreens[currentIndex],
    );
  }
}
