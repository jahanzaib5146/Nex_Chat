import 'dart:io';
import 'package:flutter/material.dart';

class FileViewer extends StatefulWidget {
  String? filePath;
  String userName;
  FileViewer({this.filePath, required this.userName});

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        leadingWidth: 20,
        title: Text(widget.userName, style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(widget.filePath!, fit: BoxFit.fill),
        ),
      ),
    );
  }
}
