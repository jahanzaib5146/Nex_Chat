import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nex_chat/Screens/Models/UserModel.dart';
import 'package:nex_chat/Screens/Models/api.dart';
import 'package:nex_chat/Screens/Models/chatModel.dart';
import 'package:nex_chat/Screens/fileViewer.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chatscreen extends StatefulWidget {
  User reciever;
  List<Chat> chats;
  User currentUser;

  Chatscreen({
    required this.reciever,
    required this.chats,
    required this.currentUser,
  });

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final _textController = TextEditingController();
  XFile? _pickedFile;
  late WebSocketChannel wsChannel;

  @override
  void initState() {
    super.initState();
    try {
      wsChannel = WebSocketChannel.connect(
        Uri.parse('${API().wsUrl}5500/?user_id=${widget.currentUser.phone}'),
      );
      wsChannel.stream.listen((data) {
        var chat = jsonDecode(data);
        widget.chats.add(Chat.fromMap(chat));
        setState(() {});
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    wsChannel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 20,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: false,
        title: Row(
          spacing: 8,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 20,
                  child: widget.reciever.profilePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.network(
                            '${API().baseUrl}${widget.reciever.profilePath}',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.person, size: 15, color: Colors.white),
                ),
              ],
            ),
            Text('${widget.reciever.name}'),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
            height: 50,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _textController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Type Message',
                  prefixIcon: IconButton(
                    onPressed: () async {
                      bool otherFile = false;
                      _pickedFile = await showModalBottomSheet<XFile>(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.camera_alt_sharp),
                                title: Text('Camera'),
                                onTap: () async {
                                  ImagePicker picker = ImagePicker();
                                  var file = await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 70,
                                  );
                                  Navigator.pop(context, file);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.photo),
                                title: Text('Gallery'),
                                onTap: () async {
                                  ImagePicker picker = ImagePicker();
                                  var file = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  Navigator.pop(context, file);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.upload),
                                title: Text('Documents'),
                                onTap: () async {
                                  FilePickerResult? pickedFile =
                                      await FilePicker.platform
                                          .pickFiles(); //picks file from phone
                                  if (pickedFile == null) return;

                                  PlatformFile p_file = pickedFile.files.first;
                                  XFile file = XFile(p_file.path!);
                                  otherFile = true;
                                  Navigator.pop(context, file);
                                },
                              ),
                            ],
                          );
                        },
                      );
                      if (_pickedFile == null) return;

                      File file = File(_pickedFile!.path);
                      Chat c = Chat(
                        sender_id: widget.currentUser.phone,
                        receiver_id: widget.reciever.phone,
                        text: "",
                        message_type: "file",
                        created_at: DateTime.now(),
                        file_url: "",
                        file: file,
                        is_read: 0,
                        otherFiles: otherFile,
                      );
                      try {
                        List<String>? resposnseList = await API().sendMessage(
                          c,
                        );
                        if (resposnseList != null) {
                          c.file_url = resposnseList[0];
                          c.orignalFileName = resposnseList[1];
                          wsChannel.sink.add(jsonEncode(c.toMap()));
                          widget.chats.add(c);
                          setState(() {});
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    },
                    icon: Icon(Icons.attachment),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      if (_textController.text.isEmpty) return;

                      Chat c = Chat(
                        sender_id: widget.currentUser.phone,
                        receiver_id: widget.reciever.phone,
                        message_type: 'text',
                        file_url: "",
                        text: _textController.text,
                        created_at: DateTime.now(),
                        orignalFileName: "",
                        otherFiles: false,
                        is_read: 0,
                      );
                      await API().sendMessage(c);
                      wsChannel.sink.add(jsonEncode(c.toMap()));
                      widget.chats.add(c);
                      _textController.clear();
                      setState(() {});
                    },
                    icon: Icon(Icons.send_rounded),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.chats.length,
                  itemBuilder: (context, index) {
                    DateTime time = widget.chats[index].created_at!;
                    return widget.chats[index].file_url!.isNotEmpty
                        ? //if file is sent
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              margin:
                                  widget.chats[index].sender_id ==
                                      widget.reciever.phone
                                  ? EdgeInsets.only(right: 120)
                                  : EdgeInsets.only(left: 120),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color:
                                    widget.chats[index].sender_id ==
                                        widget.reciever.phone
                                    ? Colors.white
                                    : const Color.fromARGB(255, 163, 250, 166),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    widget.chats[index].otherFiles!
                                        ? InkWell(
                                            onTap: () async {
                                              String url =
                                                  '${API().baseUrl}Content/Assets/Images/${widget.chats[index].file_url}';
                                              final dir =
                                                  await getApplicationDocumentsDirectory();
                                              String savePath =
                                                  '${dir.path}/${getFileName(url)}';
                                              await Dio().download(
                                                url,
                                                savePath,
                                              );
                                              OpenFile.open(savePath);
                                            },
                                            child: Container(
                                              color: Colors.grey[200],
                                              height: 50,
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          5.0,
                                                        ),
                                                    child: getIcon(
                                                      widget
                                                          .chats[index]
                                                          .orignalFileName!,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      widget
                                                          .chats[index]
                                                          .orignalFileName!,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return FileViewer(
                                                      filePath:
                                                          '${API().baseUrl}Content/Assets/Images/${widget.chats[index].file_url}',
                                                      userName:
                                                          widget.reciever.name!,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            child: Image.network(
                                              '${API().baseUrl}Content/Assets/Images/${widget.chats[index].file_url}',
                                              height: 235,
                                              width: 220,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 210),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            "${time.hour}:${time.minute}",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              margin:
                                  widget.chats[index].sender_id ==
                                      widget.reciever.phone
                                  ? EdgeInsets.only(right: 160)
                                  : EdgeInsets.only(left: 160),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color:
                                    widget.chats[index].sender_id ==
                                        widget.reciever.phone
                                    ? Colors.white
                                    : const Color.fromARGB(255, 163, 250, 166),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 13.0,
                                  top: 5.0,
                                  bottom: 5.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.chats[index].text.toString()),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 155),
                                        Text(
                                          "${time.hour}:${time.minute}",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                  },
                ),
              ),
              SizedBox(height: 58),
            ],
          ),
        ),
      ),
    );
  }

  String getFileName(String path) {
    var list = path.split('/');
    return list[list.length - 1];
  }

  Image getIcon(String fileName) {
    Image icon = Image.asset('assets/images/file.png', height: 35, width: 35);
    if (fileName.endsWith('.docx')) {
      icon = Image.asset('assets/images/word.png', height: 35, width: 35);
    } else if (fileName.endsWith('.pdf')) {
      icon = Image.asset('assets/images/pdf.png', height: 35, width: 35);
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      icon = Image.asset('assets/images/image.png', height: 35, width: 35);
    } else if (fileName.endsWith('.mp4')) {
      icon = Image.asset('assets/images/video.png', height: 35, width: 35);
    } else if (fileName.endsWith('.xlsx')) {
      icon = Image.asset('assets/images/excel.png', height: 35, width: 35);
    } else if (fileName.endsWith('.ppt')) {
      icon = Image.asset('assets/images/ppt.png', height: 35, width: 35);
    } else if (fileName.endsWith('.mp3')) {
      icon = Image.asset('assets/images/audio.png', height: 35, width: 35);
    }
    return icon;
  }
}
