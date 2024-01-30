library geddit.network;

// Import the necessary library
import 'dart:convert';

import 'package:geddit/authentication.dart';
import 'package:geddit/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart';
import 'globals.dart';
import 'json_models.dart';
import 'main.dart';

void connect() {
  StreamBuilder(
    stream: globals.channel.stream,
    builder: (context, snapshot) {
      return Text(snapshot.hasData ? '${snapshot.data}' : '');
    },
  );

  globals.channel.stream.listen((message) {
    processCommand(message);
  });
}

void processCommand(String command) {
  print(command);

  var parserCommand = json.decode(command);

  // if (parserCommand['command'] == 'auth') {
  //   if (parserCommand['status'] == '1') {
  //   } else {
  //     showLoginErrorDialog(navigatorKey.currentContext!,
  //         'Login failed. Please check your credentials.');
  //   }
  // } else if (parserCommand['command'] == 'reg') {
  //   if (parserCommand['status'] == '1') {
  //     _showRegistrationResult(
  //         navigatorKey.currentContext!, 'Registration Successful');
  //   } else {
  //     _showRegistrationResult(navigatorKey.currentContext!,
  //         'Registration Failed! Phone Number already registered');
  //   }
  // }
}

void sendMessage(WebSocketChannel channel, String message) {
  if (message.isNotEmpty) {
    channel.sink.add(message);
  }
}

Future<bool> auth(String phone, String hash) async {
  Response r = await post(Uri.parse(globals.httpLink + "/auth/login"),
      body: jsonEncode(<String, String>{'phone': phone, 'hash': hash}));
  print(r.statusCode);
  print(r.body);

  if (r.statusCode == 202) {
    saveLogin(phone, hash);
    currentUser = (await getProfile(phone, hash))!;
    listedErrands = await getListedErrands();
    return true;
  } else {
    return false;
  }
}

Future<bool> newAuth(String phone, String hash) async {
  String basicAuth = base64.encode(utf8.encode('$phone:$hash'));
  print(basicAuth);

  Response r = await get(Uri.parse(globals.httpLink + "/auth/register"),
      headers: <String, String>{'authorization': basicAuth});
  print(r.statusCode);
  print(r.body);

  if (r.statusCode == 202) {
    return true;
  } else {
    return false;
  }
}

Future<User?> getProfile(String phone, String hash) async {
  Response r = await post(Uri.parse(globals.httpLink + "/users/profile"),
      body: jsonEncode(<String, String>{'phone': phone, 'hash': hash}));

  print(r.statusCode);
  print(r.body);

  print(jsonDecode(r.body));

  if (r.statusCode == 200) {
    try {
      final parsedJson = jsonDecode(jsonDecode(r.body.toString()));
      print(parsedJson['phone']);
      final profile = User.fromJson(parsedJson);
      return profile;
    } catch (e, stackTrace) {
      print('Error decoding JSON: $e');
      print('Stack trace: $stackTrace');
      // Handle the error case
    }
  } else {
    return null;
  }
}

Future<List<Errand>> getListedErrands() async {
  Response r = await get(Uri.parse(globals.httpLink + "/errands/listed"));

  print(r.statusCode);
  print(r.body);

  print(jsonDecode(r.body));

  if (r.statusCode == 200) {
    try {
      final parsedJson = jsonDecode(jsonDecode(r.body.toString()));
      print(parsedJson['listedErrands']);

      var listedErrandsData = parsedJson['listedErrands'] as List<dynamic>?;

      return listedErrandsData != null
          ? listedErrandsData
              .map((listedErrandData) =>
                  Errand.fromJson(listedErrandData as Map<String, dynamic>))
              .toList()
          : <Errand>[];
    } catch (e, stackTrace) {
      print('Error decoding JSON: $e');
      print('Stack trace: $stackTrace');
      return <Errand>[];
    }
  } else {
    return <Errand>[];
  }
}

Future<bool> requestErrand(
    int from, int to, String desc, int price, String phone) async {
  var errand =
      Errand(from: from, to: to, desc: desc, price: price, phone: phone);

  Response r = await post(Uri.parse(globals.httpLink + "/errands/request"),
      body: jsonEncode(errand));

  if (r.statusCode == 200) {
    print('yeys');
    return true;
  } else {
    print("boo");
    return false;
  }
}
