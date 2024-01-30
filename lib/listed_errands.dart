import 'package:flutter/material.dart';
// Import the necessary library
import 'dart:convert';
import 'package:geddit/globals.dart' as globals;
import 'package:geddit/network.dart';
import 'package:geddit/utils.dart';

import 'authentication.dart';
import 'globals.dart';
import 'json_models.dart';

class ListedErrandsScreen extends StatefulWidget {
  const ListedErrandsScreen({super.key});

  @override
  ListedErrandsScreenState createState() => ListedErrandsScreenState();
}

class ListedErrandsScreenState extends State<ListedErrandsScreen>
    with AutomaticKeepAliveClientMixin<ListedErrandsScreen> {
  late String selectedFrom;
  late String selectedTo;

  late List<Errand> _filteredErrands;

  @override
  void initState() {
    super.initState();
    print("rebuilding init page");
    selectedFrom = 'Any'; // Default values for dropdowns
    selectedTo = 'Any';
    _filteredErrands = filterErrands('Any', 'Any', listedErrands);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("rebuilding page");
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
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
                                selectedFrom, selectedTo, listedErrands);
                          });
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                                selectedFrom, selectedTo, listedErrands);
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
          const SizedBox(height: 20),
          Expanded(
            child: RefreshIndicator(
              key: const PageStorageKey<String>('listedRefresher'),
              onRefresh: _pullRefresh,
              child: ListView.builder(
                key: const PageStorageKey<String>('listedErrands'),
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
              'Listed Errand - ${locations[errand.from]} to ${locations[errand.to]}'),
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
    listedErrands = await getListedErrands();
    setState(() {
      _filteredErrands = filterErrands(selectedFrom, selectedTo, listedErrands);
      Future.delayed(const Duration(seconds: 2));
    });
  }
}
