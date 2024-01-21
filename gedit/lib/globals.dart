library untitiled.globals;

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

const LOGIN_SUCCESS = 1;
const LOGIN_FAILURE = 2;
const USER_PROFILE = 3;
const NEW_ERRANDS = 4;

WebSocketChannel channel =
    IOWebSocketChannel.connect("ws://192.168.55.106:8000/ws/server/");

List<Errand> availableErrands = [];

int locCode(String location) {
  if (location == 'Bakul') {
    return 0;
  } else if (location == 'BBC') {
    return 1;
  } else if (location == 'Main Gate') {
    return 2;
  } else if (location == 'Himalaya') {
    return 3;
  } else if (location == 'JC') {
    return 4;
  } else if (location == 'NBH') {
    return 5;
  } else if (location == 'Nilgiri') {
    return 6;
  } else if (location == 'OBH') {
    return 7;
  } else if (location == 'Parijat') {
    return 8;
  } else if (location == 'VC') {
    return 9;
  } else if (location == 'Vindhya') {
    return 10;
  } else {
    return -1;
  }
}

class User {
  String name;
  String phone;

  List<Errand> myErrands = [];

  List<Errand> myDerliveries = [];

  User({required this.name, required this.phone});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}

User currentUser = User(name: "John Doe", phone: "1234567890");

class Errand {
  final String from;
  final String to;

  final String clientPhone;
  final String dphone;

  final int price;

  final String desc;

  Errand(
      {required this.from,
      required this.to,
      required this.dphone,
      required this.clientPhone,
      required this.price,
      required this.desc});

  Map<String, dynamic> toJson() => {
        'command': 'newerrand',
        'clientPhone': clientPhone,
        'from': from,
        'to': to,
        'price': price,
        'desc': desc,
        'dphone': dphone,
      };
}