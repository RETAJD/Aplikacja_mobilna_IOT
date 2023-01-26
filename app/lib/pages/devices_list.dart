import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../services/shared_service.dart';
import 'home_page_copy.dart';

class DevicesList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DevicesListState();
  }
}

class DevicesListState extends State<DevicesList> {
  late String _name;
  late String _sync;


  Map<String, String> _devices = {
  };
String userEmail = '';


Future<void> cisnienie_m() async {
    const apiUrl = 'http://192.109.244.131:3000/user_device';
    //const apiUrl = 'http://localhost:3000/user_device';

    HttpClient client = HttpClient();
    client.autoUncompress = true;

    final HttpClientRequest request = await client.getUrl(Uri.parse(apiUrl));
    request.headers
        .set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    final HttpClientResponse response = await request.close();

    final String content = await response.transform(utf8.decoder).join();
    Map<String, dynamic> data = json.decode(content);
    String data_string = data['data'].toString();


    //print(data);

    for (var i = data['data'].length -1 ; i > 0 ; i--) {

      String temperatura_string = data['data'][i]['email'].toString();
      // convert string to double

      // add new  value to Map _devices
      //print(data["data"]);
      if(temperatura_string == userEmail){
        if (!_devices.containsKey(data['data'][i]['topic'].toString())) {
          _devices.addAll({data['data'][i]['topic'].toString(): data['data'][i]['topic'].toString()});
        }
      }
    }
}



  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildName() {
    
    SharedService.loginDetails().then((value) => {
      setState(() {
        userEmail = value!.data.email;
      })
    });

    cisnienie_m ();
    

    // wywolanie funkcji przypisujacej urzadzenia do uzytkownika

    return TextFormField(
      decoration: InputDecoration(labelText: 'Podaj nazwe urzadzenia do usunięcia!'),
      maxLength: 30,
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Podaj nazwe urzadzenia do usunięcia!';
        }
        return null;
      },
      onSaved: (String? value) {
        _name = value!;
      },
    );
  }




  @override
  Widget build(BuildContext context) {

  @override
  void initState() {
    super.initState();
    // call function to get devices
    SharedService.loginDetails().then((value) => {
      setState(() {
        userEmail = value!.data.email;
      })
    });
    cisnienie_m();
  }
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                  // create buttons for each device
                  for (var device in _devices.entries)
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      // make buttons the same width
                      width: double.infinity,
                      // make buttons the same height
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          //Navigator.pushNamed(context, '/device', arguments: device.key);
                          print(device.value);
                          // navigate to HomePage_temperature() with device name as argument
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage_temperature(text: device.value.toString()),
                            ),
                          );
                           

                        },
                        child: Text(device.value),
                      ),
                    ),
                  _buildName(),
                  // create button to remove device
                  Container(
                    margin: EdgeInsets.only(bottom: 50),
                    // make buttons the same width
                    width: double.infinity,
                    // make buttons the same height
                    height: 30,
                    
                    child: ElevatedButton(
                      
                      onPressed: () {
                        _formKey.currentState!.save();
                        //Navigator.pushNamed(context, '/device', arguments: device.key);
                        print(_name);
                      },
                      child: Text('Remove device'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}

// create init state