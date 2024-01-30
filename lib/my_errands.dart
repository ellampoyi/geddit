import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Import the necessary library
import 'package:geddit/utils.dart';

import 'globals.dart';
import 'json_models.dart';
import 'network.dart';

class MyErrandsScreen extends StatefulWidget {
  const MyErrandsScreen({super.key});

  @override
  MyErrandsScreenState createState() => MyErrandsScreenState();
}

class MyErrandsScreenState extends State<MyErrandsScreen>
    with AutomaticKeepAliveClientMixin<MyErrandsScreen> {
  late String selectedFrom;
  late String selectedTo;

  List<Errand> get myErrands => currentUser.myErrands;

  late List<Errand> _filteredErrands;


  @override
  void initState() {
    super.initState();
    print("rebuilding init page");
    selectedFrom = 'Any'; // Default values for dropdowns
    selectedTo = 'Any';
    _filteredErrands = filterErrands('Any', 'Any', myErrands);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
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
                        items: locations.map((String location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFrom = value.toString();
                            _filteredErrands = filterErrands(
                                selectedFrom, selectedTo, myErrands);
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
                        items: locations.map((String location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTo = value.toString();
                            _filteredErrands = filterErrands(
                                selectedFrom, selectedTo, myErrands);
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
            child: RefreshIndicator(
              key: const PageStorageKey<String>('listedRefresher'),
              onRefresh: _pullRefresh,
              child: ListView.builder(
                key: const PageStorageKey<String>('myErrands'),
                itemCount: _filteredErrands.length,
                addAutomaticKeepAlives: true,
                itemBuilder: (context, index) {
                  print("rebuilding");
                  super.build(context);
                  return buildErrandTile(_filteredErrands[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrandTile(Errand errand) {
    return GestureDetector(
      onTap: () {
        navigateToDescription(errand);
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 18.0,
        shadowColor: Colors.cyan,
        color: Colors.cyanAccent,
        child: ListTile(
          title: Text(
              'My Errand - ${locations[errand.from]} to ${locations[errand.to]}'),
          subtitle: Text('\$${errand.price.toString()}'),
          trailing: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  void navigateToDescription(Errand errand) {
    // Implement navigation logic to the detailed description page
    // You can use Navigator.push to navigate to the description page
    // Pass the ErrandModel or relevant data to the description page
  }

  Future<void> _pullRefresh() async {
    const storage = FlutterSecureStorage();
    String? phone = await storage.read(key: "phone");
    String? hash = await storage.read(key: "hash");

    currentUser = (await getProfile(phone!, hash!))!;
    setState(() {
      _filteredErrands = filterErrands(selectedFrom, selectedTo, myErrands);
      Future.delayed(const Duration(seconds: 2));
    });
  }
}
