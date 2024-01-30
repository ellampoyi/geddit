import 'dart:convert';

import 'package:geddit/globals.dart';

class Auth {
  final String phone;
  final String hash;

  Auth(this.phone, this.hash);

  Map<String, dynamic> toJson() => {
        'command': 'auth',
        'phone': phone,
        'hash': hash,
      };
}

class Reg {
  final String phone;
  final String hash;

  Reg(this.phone, this.hash);

  Map<String, dynamic> toJson() => {
        'command': 'reg',
        'phone': phone,
        'hash': hash,
      };
}

class Errand {
  final int from;
  final int to;

  final String? phone;
  final String? dphone;

  final int price;

  final String desc;

  Errand(
      {required this.from,
      required this.to,
      required this.desc,
      required this.price,
      this.phone,
      this.dphone});

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'desc': desc,
        'price': price,
        'phone': phone,
        'dphone': dphone,
      };

  factory Errand.fromJson(Map<dynamic, dynamic> data) {
    // ! there's a problem with this code (see below)
    final from = data['from'];
    final to = data['to'];
    final desc = data['desc'];
    final price = data['price'];
    final phone = data['phone'];
    final dphone = data['dphone'];

    Errand errand = Errand(
        from: from,
        to: to,
        desc: desc,
        price: price,
        phone: phone,
        dphone: dphone);
    return errand;
  }
}

class ErrandModel {
  final String from;
  final String to;
  final int price;

  ErrandModel({required this.from, required this.to, required this.price});
}

class User {
  String phone;

  List<Errand> myErrands = [];

  List<Errand> myDeliveries = [];

  User({required this.phone});

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
    };
  }

  factory User.fromJson(Map<dynamic, dynamic> data) {
    // ! there's a problem with this code (see below)
    final phone = data['phone'];

    var myErrandsData = data['myErrands'] as List<dynamic>?;
    var myDeliveriesData = data['myDeliveries'] as List<dynamic>?;

    User profile = User(phone: phone);

    print(profile);

    profile.myErrands = myErrandsData != null
        ? myErrandsData
            .map((myErrandData) =>
                Errand.fromJson(myErrandData as Map<String, dynamic>))
            .toList()
        : <Errand>[];
    profile.myDeliveries = myDeliveriesData != null
        ? myDeliveriesData
            .map((myDeliveryData) =>
                Errand.fromJson(myDeliveryData as Map<String, dynamic>))
            .toList()
        : <Errand>[];

    return profile;
  }
}
