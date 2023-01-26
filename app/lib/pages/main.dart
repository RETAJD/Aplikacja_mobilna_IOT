import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/shared_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: MyHomePage(),  //MyHomePage(title: 'IOT APP'),
      );
}


class MyHomePage extends StatefulWidget {
  // add username as required parameter to constructor
  MyHomePage({Key? key}) :  super(key: key);
  

  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {

  final _writeController = TextEditingController();
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  String userName = "";
  String userEmail = "";


  var counter=0;
  
  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        if (device.name.contains("BLE_")) {  //
          widget.devicesList.add(device);
        }
      });
    }
  }

  @override
  void initState() {

    SharedService.loginDetails().then((value) => {
      setState(() {
        userName = value!.data.username;
        userEmail = value.data.email;
      })
    });
    
    super.initState();
    

    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  ListView _buildListViewOfDevices() {

    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        SizedBox(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              TextButton(
                child: const Text(
                  'Connect',
                  style: TextStyle(color: Color.fromARGB(255, 211, 218, 227)),
                ),
                onPressed: () async {
                  widget.flutterBlue.stopScan();
                  try {
                    await device.connect();
                  } on PlatformException catch (e) {
                    if (e.code != 'already_connected') {
                      rethrow;
                    }
                  } finally {
                    _services = await device.discoverServices();
                  }
                  setState(() {
                    _connectedDevice = device;
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
    BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = <ButtonTheme>[];
    // jezeli charakterystyka ma uuid == 0000ffe1-0000-1000-8000-00805f9b34fb to dodaj przyciski
    if(characteristic.uuid.toString() == '0000ff52-0000-1000-8000-00805f9b34fb'){   //00002a00-0000-1000-8000-00805f9b34fb
        // jezeli charakterystyka ma wlasciwosc read to wyswietl jej wartosc printem w konsoli
        if (characteristic.properties.read) {
          buttons.add(
            ButtonTheme(
              minWidth: 10,
              height: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextButton(
                  child: const Text('ZAPISZ URZĄDZENIE', style: TextStyle(color: Color.fromARGB(255, 225, 233, 237))),
                  onPressed: () async {
                    var sub = characteristic.value.listen((value) {
                      setState(() {
                        widget.readValues[characteristic.uuid] = value;
                      });
                    });
                    await characteristic.read();
                    sub.cancel();

                    var sub1 = characteristic.value.listen((value) {
                      setState(() {
                        widget.readValues[characteristic.uuid] = value;
                      });
                    });
                    await characteristic.read();
                    sub.cancel();
                    print("READ: " + widget.readValues[characteristic.uuid].toString());

                    // decimal to hex string conversion

                    var mac = widget.readValues[characteristic.uuid];
                    var macString = mac!.map((e) => e.toRadixString(16).padLeft(2,'0')).join(':');

                    String macString_original = macString.toUpperCase();
                    
                    //WYSLIJ DO API WARTOSC I EMAIL UZYTKOWNIK
                    const apiUrl = 'http://192.109.244.131:3000/user_device';

                    HttpClient client = HttpClient();
                    client.postUrl(Uri.parse(apiUrl)).then((HttpClientRequest request) {
                      request.headers.set('content-type', 'application/json');
                      request.add(utf8.encode(json.encode({ 'email': userEmail, 'topic': macString_original })));
                      return request.close();
                    }).then((HttpClientResponse response) {
                      print(response.statusCode);
                    });

                    // pomyslnie dodano urzadzenie do bazy alert
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Pomyślnie dodano urządzenie do twojego konta"),
                          actions: [
                            TextButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        }
    }

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              child: const Text('READ', style: TextStyle(color: Color.fromARGB(255, 225, 233, 237))),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child: const Text('WRITE', style: TextStyle(color: Color.fromARGB(255, 90, 134, 210))),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _writeController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Send"),
                            onPressed: () {
                              counter ++;
                              if(_writeController.value.text != '1'){
                                characteristic.write(
                                  utf8.encode(_writeController.value.text));
                              }
                              else{
                                // write to characteristic UnsignedInt value 
                                characteristic.write(
                                   // UnsignedInt value = 1
                                Uint8List.fromList([0x01])
                                  ) ;
                              }
                              if(counter == 2 ){
                                   // make alert that "Successfully connected  the device to wifi"
                                   //  Navigator.pop(context);

                                    print("Successfully connected  the device to wifi");
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Wprowadzono dane, obserwuj płytkę!"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text("Zamknij"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });

                                      //Navigator.pop(context);

                              }
                              else{
                                Navigator.pop(context);
                              }
                            },
                          ),
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child:
                  const Text('NOTIFY', style: TextStyle(color: Color.fromARGB(255, 185, 208, 227))),
              onPressed: () async {
                characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  ListView _buildConnectDeviceView() {
    List<Widget> containers = <Widget>[];

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = <Widget>[];

      for (BluetoothCharacteristic characteristic in service.characteristics) {

        // if characteristic uuid == 00001801-0000-1000-8000-00805f9b34fb print found service

        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Value: ${widget.readValues[characteristic.uuid]}'),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        ExpansionTile(
            title: Text(service.uuid.toString()),
            children: characteristicsWidget),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) {

    print ("witaj: " +userEmail);

    return Scaffold(
        body: _buildView(),
            
    );
  }
}