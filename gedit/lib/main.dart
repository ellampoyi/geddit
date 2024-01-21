import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the necessary library
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geddit/globals.dart' as globals;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String user = '';

void main() {
  // ignore: unused_local_variable
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  StreamBuilder(
    stream: globals.channel.stream,
    builder: (context, snapshot) {
      return Text(snapshot.hasData ? '${snapshot.data}' : '');
    },
  );

  

  globals.channel.stream.listen((message) {
    processCommand(message);
  });

  runApp(MyApp());
}

void processCommand(String command) {
  print(command);

  var parserCommand = json.decode(command);

  if (parserCommand['command'] == 'auth') {
    if (parserCommand['status'] == '1') {
      navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyHomePage()),
          ModalRoute.withName("/Home"));
    } else {
      showLoginErrorDialog(navigatorKey.currentContext!,
          'Login failed. Please check your credentials.');
    }
  } else if (parserCommand['command'] == 'reg') {
    if (parserCommand['status'] == '1') {
      _showRegistrationResult(
          navigatorKey.currentContext!, 'Registration Successful');
    } else {
      _showRegistrationResult(navigatorKey.currentContext!,
          'Registration Failed! Phone Number already registered');
    }
  }
}

void sendMessage(WebSocketChannel channel, String message) {
  if (message.isNotEmpty) {
    channel.sink.add(message);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        primaryColor: Colors.transparent,
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF8C5D7),
          ),
          headline2: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF8C5D7),
          ),
          bodyText1: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          button: TextStyle(
            fontSize: 18,
            color: Color(0xFFF8C5D7),
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Add GEDDIT text in bold
            Text(
              'GEDDIT',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8C5D7), // Use theme color
              ),
            ),
            SizedBox(height: 80),
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                String phoneNumber = phoneNumberController.text;
                String hashedPassword = _hashPassword(passwordController.text);

                if (phoneNumber == '' || passwordController.text == '') {
                  showLoginErrorDialog(
                      context, 'Phone number or Password cannot be empty');
                } else {
                  Auth check = Auth(phoneNumber, hashedPassword);
                  String checkJSON = jsonEncode(check);

                  sendMessage(globals.channel, checkJSON);

                  user = phoneNumberController.text;
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Login'),
            ),
            SizedBox(height: 16.0),
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
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}


  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  // Additional methods or widgets for handling login logic can be added here


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
        padding: EdgeInsets.all(16.0),
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
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Add registration logic here
                String phoneNumber = phoneNumberController.text;
                String hashedPassword = _hashPassword(passwordController.text);
                String hashedconfirmPassword =
                    _hashPassword(confirmPasswordController.text);

                if (hashedPassword == hashedconfirmPassword) {
                  Reg check = Reg(phoneNumber, hashedPassword);
                  String checkJSON = jsonEncode(check);

                  sendMessage(globals.channel, checkJSON);
                } else {
                  _showRegistrationResult(context, "Passwords DO NOT match");
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Set the border radius here
                ),
              ),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

void _showRegistrationResult(BuildContext context, String result) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Registration Result'),
        content: Text(result),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

void showLoginErrorDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Login Error'),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

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

// ###################################################################################################################################

class ErrandModel {
  final String from;
  final String to;
  final int price;

  ErrandModel({required this.from, required this.to, required this.price});
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          MyErrandsScreen(),
          ListedErrandsScreen(),
          RequestErrandsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'My Errands',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Listed Errands',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Request Errands',
          ),
        ],
      ),
    );
  }
}

class MyErrandsScreen extends StatefulWidget {
  @override
  _MyErrandsScreenState createState() => _MyErrandsScreenState();
}

class _MyErrandsScreenState extends State<MyErrandsScreen> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text('\n  MY \n  ERRANDS\n',
              style: Theme.of(context).textTheme.headline2),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(),
          ),
          SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<ErrandModel>>(
              // Replace with your logic to fetch My Errands list from the server

              future: fetchMyErrands(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<ErrandModel> myErrands = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: myErrands.length,
                    itemBuilder: (context, index) {
                      return buildErrandTile(myErrands[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrandTile(ErrandModel errand) {
    return GestureDetector(
      onTap: () {
        navigateToDescription(errand);
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 3.0,
        child: ListTile(
          title: Text('My Errand - ${errand.from} to ${errand.to}'),
          subtitle: Text('\$${errand.price.toString()}'),
          trailing: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  void navigateToDescription(ErrandModel errand) {
    // Implement navigation logic to the detailed description page
    // You can use Navigator.push to navigate to the description page
    // Pass the ErrandModel or relevant data to the description page
  }

  Future<List<ErrandModel>> fetchMyErrands() async {
    List<ErrandModel> list = List.empty();

    for (int i = 0; i < globals.currentUser.myErrands.length; ++i) {
      ErrandModel errandModel = ErrandModel(
          from: globals.currentUser.myErrands[i].from,
          to: globals.currentUser.myErrands[i].to,
          price: globals.currentUser.myErrands[i].price);
      list.add(errandModel);
    }
    // Replace with your logic to fetch My Errands from the server
    // Return a List<ErrandModel> based on the server response
    return list;
  }
}

class ListedErrandsScreen extends StatefulWidget {
  @override
  _ListedErrandsScreenState createState() => _ListedErrandsScreenState();
}

class _ListedErrandsScreenState extends State<ListedErrandsScreen> {
  late String selectedFrom;
  late String selectedTo;

  @override
  void initState() {
    super.initState();
    selectedFrom = 'VC'; // Default values for dropdowns
    selectedTo = 'Bakul';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text('\n  LISTED \n  ERRANDS\n',
              style: Theme.of(context).textTheme.headline2),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        value: selectedFrom,
                        decoration: InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        items: [
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
                          'Vindhya'
                        ].map((String location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFrom = value.toString();
                          });
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: selectedTo,
                        decoration: InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        items: [
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
                          'Vindhya'
                        ].map((String location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTo = value.toString();
                          });
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<ErrandModel>>(
              // Replace with your logic to fetch Listed Errands list from the server
              future: fetchListedErrands(selectedFrom, selectedTo),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<ErrandModel> listedErrands = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: listedErrands.length,
                    itemBuilder: (context, index) {
                      return buildErrandTile(listedErrands[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrandTile(ErrandModel errand) {
    return GestureDetector(
      onTap: () {
        navigateToDescription(errand);
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 3.0,
        child: ListTile(
          title: Text('Listed Errand - ${errand.from} to ${errand.to}'),
          subtitle: Text('\$${errand.price.toString()}'),
          trailing: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  void navigateToDescription(ErrandModel errand) {
    // Implement navigation logic to the detailed description page
    // You can use Navigator.push to navigate to the description page
    // Pass the ErrandModel or relevant data to the description page
  }

  Future<List<ErrandModel>> fetchListedErrands(String from, String to) async {
    // Replace with your logic to fetch Listed Errands from the server
    // Return a List<ErrandModel> based on the server response and filtering criteria
    // For now, returning a dummy list sorted based on the selected locations
    List<ErrandModel> dummyList = [
      ErrandModel(from: 'Bakul', to: 'BBC', price: 20),
      ErrandModel(from: 'Bakul', to: 'VC', price: 15),
      ErrandModel(from: 'BBC', to: 'Main Gate', price: 25),
      ErrandModel(from: 'Main Gate', to: 'Bakul', price: 18),
    ];

    return dummyList
        .where(
            (errand) => errand.from == selectedFrom && errand.to == selectedTo)
        .toList()
      ..sort((a, b) => a.price.compareTo(b.price));
  }
}

class RequestErrandsScreen extends StatelessWidget {
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String f = '';
    String t = '';
    final TextEditingController priceController = TextEditingController();

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text('\n  REQUEST \n  ERRANDS\n',
              style: Theme.of(context).textTheme.headline2),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        items: [
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
                          'Vindhya'
                        ].map((String location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          f = value!;
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        items: [
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
                          'Vindhya'
                        ].map((String location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          t = value!;
                          // Handle dropdown value changes
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  maxLength: 255,
                  maxLines: 5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price for Delivery',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    sendErrand newerrand = sendErrand(
                        from: globals.locCode(f),
                        to: globals.locCode(t),
                        dphone: '',
                        clientPhone: user,
                        price: int.parse(priceController.text),
                        desc: descriptionController.text);

                    String newerrandJSON = jsonEncode(newerrand);
                    sendMessage(globals.channel, newerrandJSON);
                    // Add logic to handle form submission
                  },
                  child:
                      Text('Submit', style: Theme.of(context).textTheme.button),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class sendErrand {
  final int from;
  final int to;

  final String clientPhone;
  final String dphone;

  final int price;

  final String desc;

  sendErrand(
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
