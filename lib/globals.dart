library geddit.globals;

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'json_models.dart';

const LOGIN_SUCCESS = 1;
const LOGIN_FAILURE = 2;
const USER_PROFILE = 3;
const NEW_ERRANDS = 4;

const AUTHENTICATION_SUCCESS = 1;
const AUTHENTICATION_FAILURE = 0;

const wssLink = "ws://192.168.55.106:8000/ws/server";
const httpLink = "http://192.168.55.106:8000/server";

WebSocketChannel channel = IOWebSocketChannel.connect(wssLink);

User currentUser = User(phone: "1234567890");

List<Errand> availableErrands = [];

List<String> locations = [
  'Bakul',
  'BBC',
  'Main Gate',
  'Himalaya',
  'JC',
  'NBH',
  'Nilgiri',
  'OBH',
  'Parijat',
  'VC',
  'Vindhya',
  'Any'
];

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
  } else if (location == 'Any') {
    return 11;
  }
  else {
    return 0;
  }
}

List<Errand> listedErrands = [];
