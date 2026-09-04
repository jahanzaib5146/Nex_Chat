import 'package:flutter/material.dart';
import 'package:nex_chat/Screens/ChatScreen.dart';
import 'package:nex_chat/Screens/Models/api.dart';
import 'package:nex_chat/Screens/Models/chatModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'Models/UserModel.dart';

class Homescreen extends StatefulWidget {
  User? currentUser;

  Homescreen({required this.currentUser});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  bool loading = true;
  List<User> contacts = [];
  Map<String, dynamic> chats = {};
  late WebSocketChannel wsChatChannel;
  late WebSocketChannel wsStatusChannel;

  @override
  void initState() {
    super.initState();
    loadInitials();
  }

  startListening() {
    try {
      //This is chat ws channel block
      wsChatChannel = WebSocketChannel.connect(
        Uri.parse('${API().wsUrl}5500/?user_id=${widget.currentUser!.phone}'),
      );

      wsChatChannel.stream.listen((data) {
        //'yahan bilkul ata hi nai
        var chat = jsonDecode(data);
        print(chat);
        String senderId = chat["sender_id"];
        setState(() {
          if (chats.containsKey(senderId)) {
            chats[senderId]!.add(Chat.fromMap(chat));
          } else {
            chats[senderId] = [Chat.fromMap(chat)];
          }
        });
      });
    } catch (e) {
      print('ye error hy bhai Home me \n ${e.toString()}');
    }
  }

  void loadInitials() async {
    loadContacts();
    await Future.delayed(Duration(seconds: 1));

    try {
      //This block is for status checking webSocket
      wsStatusChannel = WebSocketChannel.connect(
        Uri.parse('${API().wsUrl}5600/?user_id=${widget.currentUser!.phone}'),
      );
      wsStatusChannel.stream.listen((data) {
        var msg = jsonDecode(data);
        int contactIndex = contacts.indexWhere(
          (c) => c.phone == msg['user_id'],
        );
        if (contactIndex != -1) {
          setState(() {
            contacts[contactIndex].status = msg['status'];
          });
        }
      });
    } catch (e) {
      print('ye error hy bhai\n${e.toString()}');
    }
  }

  @override
  void dispose() {
    //wsChatChannel.sink.close();
    wsStatusChannel.sink.close();
    super.dispose();
  }

  void loadContacts() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String contactsJson = sp.getString('${widget.currentUser!.phone}') ?? '';
    if (contactsJson.isNotEmpty) {
      contacts = (jsonDecode(contactsJson) as List)
          .map((e) => User.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    loadChats();
    setState(() {
      loading = false;
    });
  }

  void loadChats() async {
    for (int i = 0; i < contacts.length; i++) {
      List<Chat> ch = await API().getChats(
        contacts[i].phone!,
        widget.currentUser!.phone!,
      );
      chats[contacts[i].phone!] = ch;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search Contacts',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onLongPress: () async {
                            bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text('Do you want to Delete Chat ?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: Text('Ok'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirm != true) return;
                            contacts.removeAt(index);
                            SharedPreferences sp =
                                await SharedPreferences.getInstance();
                            await sp.setString(
                              '${widget.currentUser!.phone}',
                              jsonEncode(
                                contacts.map((c) => c.toMap()).toList(),
                              ),
                            );
                            setState(() {});
                          },
                          onTap: () async {
                            List<Chat> userChat =
                                chats[contacts[index].phone!] ?? [];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Chatscreen(
                                  reciever: contacts[index],
                                  chats: userChat,
                                  currentUser: widget.currentUser!,
                                ),
                              ),
                            );
                          },
                          tileColor: Colors.white,
                          minTileHeight: 70,
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                radius: 25,
                                child: contacts[index].profilePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(35),
                                        child: Image.network(
                                          '${API().baseUrl}${contacts[index].profilePath}',
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
                            '${contacts[index].name}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            spacing: 5,
                            children: [
                              CircleAvatar(
                                radius: 5,
                                backgroundColor:
                                    contacts[index].status == "online"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              contacts[index].status == "online"
                                  ? Text('Online')
                                  : Text('Offline'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
