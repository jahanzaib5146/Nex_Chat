import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Models/UserModel.dart';

class Profilescreen extends StatefulWidget {
  User? user;
  Profilescreen({this.user});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 30),
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 70,
                      child: widget.user!.profilePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.network(
                                widget.user!.profilePath!,
                                width: 128,
                                height: 128,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Edit',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            ),
            SizedBox(height: 20),
            Text('WelCome to NexChat', style: TextStyle(fontSize: 23)),
            SizedBox(height: 20),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${widget.user!.name}'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(
                'Contact',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${widget.user!.phone}'),
            ),
          ],
        ),
      ),
    );
  }
}
