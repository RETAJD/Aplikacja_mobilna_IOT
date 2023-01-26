import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class FormScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<FormScreen> {
  late String _name;
  late String _sync;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildName() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Podaj co ile sekund bedzie robiony pomiar!'),
      maxLength: 10,
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Podaj co ile sekund bedzie robiony pomiar!';
        }
        return null;
      },
      onSaved: (String? value) {
        _name = value!;
      },

      
    );
  }

Widget set_sync() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Podaj co ile wykonuj sync!'),
      maxLength: 10,
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Podaj co ile wykonuj sync!';
        }
        return null;
      },
      onSaved: (String? value) {
        _sync = value!;
      },
    );
  }

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                // add button to return to home page
                ElevatedButton(
                  child: Text('Back'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                set_sync(),
                TextButton(
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  onPressed: () {
                    _formKey.currentState!.save();
                    //print(_name);

                    //Send to API  i w api wyslac na mqtt
                    print(_sync);
                    // make post request to localhost:3000/measure with body: {name: _name}
                    const apiUrl = 'http://192.109.244.131:3000/sync_time';
                    //const apiUrl = 'http://localhost:3000/sync_time';

//
                    HttpClient client = HttpClient();
                    client.postUrl(Uri.parse(apiUrl)).then((HttpClientRequest request) {
                      request.headers.set('content-type', 'application/json');
                      request.add(utf8.encode(json.encode({'name': _sync})));
                      return request.close();
                    }).then((HttpClientResponse response) {
                      print(response.statusCode);
                    });

                     
                    // create monit that success
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Success!'),
                      ),
                    );
                  },
                ),
                _buildName(),
                TextButton(
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  onPressed: () {

                    _formKey.currentState!.save();
                    //print(_name);

                    //Send to API  i w api wyslac na mqtt

                    // make post request to localhost:3000/measure with body: {name: _name}
                    const apiUrl = 'http://192.109.244.131:3000/measure';
                    //const apiUrl = 'http://localhost:3000/measure';

                    HttpClient client = HttpClient();
                    client.postUrl(Uri.parse(apiUrl)).then((HttpClientRequest request) {
                      request.headers.set('content-type', 'application/json');
                      request.add(utf8.encode(json.encode({'name': _name})));
                      return request.close();
                    }).then((HttpClientResponse response) {
                      print(response.statusCode);
                    });

                     
                    // create monit that success
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Success!'),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}