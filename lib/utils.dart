library geddit.utils;

import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'globals.dart';
import 'json_models.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

List<Errand> filterErrands(String from, String to, List<Errand> errands) {
  List<Errand> list = errands;

  print("rebuilding");

  List<Errand> anyList = list.toList()
    ..sort((a, b) => b.price.compareTo(a.price));

  List<Errand> fromList = list
      .where((errand) => errand.from == locCode(from))
      .toList()
    ..sort((a, b) => b.price.compareTo(a.price));

  List<Errand> toList = list
      .where((errand) => errand.to == locCode(to))
      .toList()
    ..sort((a, b) => b.price.compareTo(a.price));

  List<Errand> fromToList = list
      .where(
          (errand) => errand.from == locCode(from) && errand.to == locCode(to))
      .toList()
    ..sort((a, b) => b.price.compareTo(a.price));

  if (to == 'Any' && from == 'Any') {
    return anyList;
  } else if (from == 'Any') {
    return toList;
  } else if (to == 'Any') {
    return fromList;
  } else {
    return fromToList;
  }
}
