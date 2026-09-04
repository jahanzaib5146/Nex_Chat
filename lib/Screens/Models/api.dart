import 'dart:convert';
import 'package:nex_chat/Screens/Models/chatModel.dart';
import 'UserModel.dart';
import 'package:http/http.dart' as http;

class API {
  String baseUrl = "http://10.50.157.4/NexChatServices/";
  String wsUrl = "ws://10.50.157.4:";

  Future<String> addUser(User user) async {
    String url = "${baseUrl}api/registration/AddUser";
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields['name'] = user.name.toString();
    request.fields['password'] = user.password.toString();
    request.fields['phone'] = user.phone.toString();
    var file = await http.MultipartFile.fromPath(
      'profile_image',
      user.profile_image!.path,
    );
    request.files.add(file);
    request.headers['Accept'] = 'application/json';
    var streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return 'Signed Up Successfully';
    } else if (response.statusCode == 302) {
      return 'Phone No already registerd';
    } else {
      return 'Internal Server error';
    }
  }

  Future<http.Response> login(User u) async {
    String url = '${baseUrl}api/registration/Login';
    var userMap = u.toMap();

    var userJson = jsonEncode(userMap);

    var response = await http.post(
      Uri.parse(url),
      body: userJson,
      headers: {'Content-Type': 'application/json'},
    );

    return response;
  }

  Future<http.Response> getUser(String phone) async {
    String url = '${baseUrl}api/Chat/getUser?phone=$phone';
    var response = await http.get(Uri.parse(url));
    return response;
  }

  Future<List<Chat>> getChats(String receiver, String sender) async {
    String url =
        '${baseUrl}api/Chat/getchats?Receiver=$receiver&Sender=$sender';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var chats = jsonDecode(response.body);

      if (chats is List) {
        List<Chat> chatsList = chats.map((x) => Chat.fromMap(x)).toList();
        return chatsList;
      }
    }
    return [];
  }

  Future<List<String>?> sendMessage(Chat c) async {
    String url = "${baseUrl}api/chat/sendMessage";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['sender_id'] = c.sender_id!;
    request.fields['receiver_id'] = c.receiver_id!;
    request.fields['message_type'] = c.message_type!;
    request.fields['otherFiles'] = c.otherFiles!.toString();
    if (c.message_type == 'text') {
      request.fields['text'] = c.text!;
    } else if (c.message_type == 'file') {
      var file = await http.MultipartFile.fromPath('file', c.file!.path);
      request.headers['Accept'] = 'application/json';
      request.files.add(file);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      List<String> resList = [];
      resList.add(body['file_url']);
      resList.add(body['orignalFileName']);
      return resList;
    }
    return null;
  }
}
