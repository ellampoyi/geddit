import 'package:flutter/material.dart';
// Import the necessary library
import 'dart:convert';
import 'package:geddit/globals.dart' as globals;
import 'package:geddit/network.dart';

import 'authentication.dart';
import 'globals.dart';
import 'json_models.dart';

class RequestErrandsScreen extends StatefulWidget
{
  const RequestErrandsScreen({super.key});

  @override
  State<RequestErrandsScreen> createState() => _RequestErrandsScreenState();
}

class _RequestErrandsScreenState extends State<RequestErrandsScreen> with AutomaticKeepAliveClientMixin<RequestErrandsScreen> {

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String f = '';
    String t = '';

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
                        items: locations.map((String location) {
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
                    requestErrand(
                        globals.locCode(f),
                        globals.locCode(t),
                        descriptionController.text,
                        int.parse(priceController.text),
                        currentUser.phone);
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
