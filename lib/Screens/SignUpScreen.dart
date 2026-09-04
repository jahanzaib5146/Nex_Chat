import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nex_chat/Screens/LoginScreen.dart';
import 'package:nex_chat/Screens/Models/UserModel.dart';
import 'package:nex_chat/Screens/Models/api.dart';
import 'validators.dart';
import 'package:image_picker/image_picker.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passWordController = TextEditingController();
  final _confirmPassWordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _hideShowPassword = true;
  bool _hideShowConfirmPassword = true;
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                spacing: 15,
                children: [
                  SizedBox(height: 30),
                  Stack(
                    children: [
                      GestureDetector(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          radius: 60,
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.file(
                                    _imageFile!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                        ),
                        onTap: () async {
                          ImagePicker _picker = ImagePicker();
                          XFile? file = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );

                          if (file != null) {
                            File imageFile = File(file.path);
                            setState(() {
                              _imageFile = imageFile;
                            });
                          }
                        },
                      ),
                      Positioned(
                        child: Icon(Icons.camera_alt),
                        top: 90,
                        left: 90,
                      ),
                    ],
                  ),
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
                    controller: _nameController,
                    validator: (value) => userNameValidator(value),
                    decoration: InputDecoration(
                      hintText: 'Enter UserName',
                      labelText: 'UserName',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextFormField(
                    obscureText: _hideShowPassword,
                    controller: _passWordController,
                    validator: (value) => passWordValidator(value),
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        child: Icon(
                          _hideShowPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onTap: () {
                          _hideShowPassword = !_hideShowPassword;
                          setState(() {});
                        },
                      ),
                      hintText: 'Enter Password',
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextFormField(
                    obscureText: _hideShowConfirmPassword,
                    controller: _confirmPassWordController,
                    validator: (value) => confirmPassWordValidator(value),
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        child: Icon(
                          _hideShowConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onTap: () {
                          _hideShowConfirmPassword = !_hideShowConfirmPassword;
                          setState(() {});
                        },
                      ),
                      hintText: 'Confirm Password',
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        User u = User(
                          phone: _phoneController.text,
                          name: _nameController.text,
                          password: _passWordController.text,
                          profile_image: _imageFile,
                        );

                        String response = await API().addUser(u);

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(response)));
                        if (response == "Signed Up Successfully") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (content) {
                                return Loginscreen();
                              },
                            ),
                          );
                        }
                      }
                    },
                    child: Text('SignUp'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? confirmPassWordValidator(String? cPass) {
    if (cPass!.isEmpty || cPass != _passWordController.text) {
      return "Password must be Same";
    }
    return null;
  }
}
