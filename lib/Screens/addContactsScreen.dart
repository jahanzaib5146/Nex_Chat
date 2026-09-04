import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nex_chat/Screens/Models/UserModel.dart';
import 'package:nex_chat/Screens/Models/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'validators.dart';

class AddContactsScreen extends StatefulWidget {
  User currentUser;
  AddContactsScreen({required this.currentUser});
  @override
  State<AddContactsScreen> createState() => _AddContactsScreenState();
}

class _AddContactsScreenState extends State<AddContactsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  List<Map<String, dynamic>> contacts = [];
  User? user;
  bool? userFound = null;
  User? currentUser;

  void initState() {
    super.initState();
    currentUser = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              SizedBox(height: 20),
              Center(
                child: Text('Add Contact', style: TextStyle(fontSize: 30)),
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
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var response = await API().getUser(_phoneController.text);
                      if (response.statusCode == 200) {
                        //user Found
                        var userMap = jsonDecode(response.body);
                        user = User.fromMap(userMap);
                        SharedPreferences sp =
                            await SharedPreferences.getInstance();

                        if (user!.phone == currentUser!.phone) {
                          return;
                        }

                        String list =
                            sp.getString('${currentUser!.phone}') ?? '';

                        if (list.isNotEmpty) {
                          contacts = List<Map<String, dynamic>>.from(
                            jsonDecode(list),
                          );
                        }
                        bool exists = contacts.any(
                          (c) => c['phone'] == userMap['phone'],
                        );
                        if (!exists) {
                          contacts.add(userMap);
                          sp.setString(
                            '${currentUser!.phone}',
                            jsonEncode(contacts),
                          );
                          userFound = true;
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('User Added Successfully.....!'),
                            ),
                          );
                          _phoneController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User Already Added.....!')),
                          );
                          userFound = true;
                        }
                      } else {
                        userFound = false;
                      }
                      setState(() {});
                    }
                  },
                  child: Text('Add'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Contact Details :',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              userFound == null
                  ? SizedBox()
                  : userFound == false
                  ? Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'No User Found!',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    )
                  : ListTile(
                      tileColor: Colors.grey[400],
                      minTileHeight: 70,
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            radius: 25,
                            child: user!.profilePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(35),
                                    child: Image.network(
                                      '${API().baseUrl}${user!.profilePath!}',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                          ),
                        ],
                      ),
                      title: Text(
                        '${user!.name}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${user!.phone}'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
