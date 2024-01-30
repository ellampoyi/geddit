import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the necessary library
import 'dart:convert';
import 'package:geddit/globals.dart' as globals;
import 'package:geddit/utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'json_models.dart';
import 'main.dart';
import 'network.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Add GEDDIT text in bold
            const Text(
              'GEDDIT',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8C5D7), // Use theme color
              ),
            ),
            const SizedBox(height: 80),
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                String phoneNumber = phoneNumberController.text;
                String hashedPassword = hashPassword(passwordController.text);

                if (phoneNumber == '' || passwordController.text == '') {
                  showErrorDialog(context, "Invalid Credentials",
                      'Phone number or Password cannot be empty');
                } else {
                  login(context, phoneNumber, hashedPassword);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void login(BuildContext buildContext, String username, String hash) async {
    if (await auth(username, hash)) {
      navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyHomePage()),
          ModalRoute.withName("/Home"));
      connect();
    } else {
      if (buildContext.mounted) {
        showErrorDialog(buildContext, "Login Error!", "Invalid Credentials!");
      }
    }
  }
}

class RegisterPage extends StatelessWidget {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Register Page'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone, // Set input type to phone
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9]')), // Allow only numeric input
              ],
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Add registration logic here
                String phoneNumber = phoneNumberController.text;
                String hashedPassword = hashPassword(passwordController.text);
                String hashedConfirmPassword =
                    hashPassword(confirmPasswordController.text);

                if (hashedPassword == hashedConfirmPassword) {
                  Reg check = Reg(phoneNumber, hashedPassword);
                  String checkJSON = jsonEncode(check);

                  register(context, phoneNumber, hashedPassword);
                } else {
                  showErrorDialog(context, "Invalid Credentials!",
                      "Passwords do not match!");
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Set the border radius here
                ),
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void register(BuildContext buildContext, String username, String hash) async {
    if (await newAuth(username, hash)) {
      if (buildContext.mounted) {
        showErrorDialog(buildContext, "Registration Success!", "Login in!");
      }
    } else {
      if (buildContext.mounted) {
        showErrorDialog(
            buildContext, "Cannot Register!", "Phone Number exists!");
      }
    }
  }
}

void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<bool> autoLogin() async {
  const storage = FlutterSecureStorage();
  String? phone = await storage.read(key: "phone");
  String? hash = await storage.read(key: "hash");

  if (phone != null && hash != null) {
    print(phone + " " + hash);
    return await auth(phone, hash);
  } else {
    return false;
  }
}

void saveLogin(String phone, String hash) async {
  var storage = const FlutterSecureStorage();

  print(phone + " " + hash);
  await storage.write(key: "phone", value: phone);
  await storage.write(key: "hash", value: hash);
}
