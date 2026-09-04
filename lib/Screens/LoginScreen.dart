import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nex_chat/Screens/Models/UserModel.dart';
import 'package:nex_chat/Screens/Models/api.dart';
import 'package:nex_chat/Screens/NavBarScreen.dart';
import 'package:nex_chat/Screens/SignUpScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'validators.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passWordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 5,
            children: [
              Image.asset(
                "assets/images/icons8-chat-100.png",
                color: Colors.black,
              ),
              Text(
                'NexChat',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                validator: (value) => phoneValidator(value),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Phone No',
                  labelText: 'Phone No',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              TextFormField(
                obscureText: true,
                controller: _passWordController,
                validator: (value) => passWordValidator(value),
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    User u = User(
                      phone: _phoneController.text,
                      password: _passWordController.text,
                    );

                    var response = await API().login(u);
                    if (response.statusCode == 203) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid Credentials')),
                      );
                    } else if (response.statusCode == 200) {
                      var body = jsonDecode(response.body);
                      u = User.fromMap(body);
                      u.profilePath = '${API().baseUrl}${u.profilePath}';

                      SharedPreferences sp =
                          await SharedPreferences.getInstance();
                      sp.setString('user', jsonEncode(u.toMap()));

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Navbarscreen(user: u);
                          },
                        ),
                      );
                    }
                  }
                },
                child: Text('Login'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have Acoount/',
                    style: TextStyle(color: Colors.black),
                  ),
                  GestureDetector(
                    child: Text('SignUp', style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Signupscreen();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
