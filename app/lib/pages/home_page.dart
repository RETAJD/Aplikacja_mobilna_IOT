import 'package:IOT_APP_KONCOWA_WERSJA/pages/configuration.dart';
import 'package:IOT_APP_KONCOWA_WERSJA/pages/home_page_copy.dart';
import 'package:IOT_APP_KONCOWA_WERSJA/pages/main.dart';
import 'package:IOT_APP_KONCOWA_WERSJA/pages/start_with_logo.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/shared_service.dart';
import 'devices_list.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentPageIndex ;
  final List<Widget> _pages = [];

  String userName = "";
  String userEmail = "";

  

  Widget _getCurrentPage() => _pages[_currentPageIndex];

  @override
  void initState() {
    
    setState(() {

    SharedService.loginDetails().then((value) => {
      setState(() {
        userName = value!.data.username;
        userEmail = value.data.email;
      })
    });
      
      _currentPageIndex = 0;
      _pages.add(WelcomePage());
      _pages.add(DevicesList());
      _pages.add(MyHomePage());
      _pages.add(FormScreen());

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Witaj, $userName w IOT APP"),
        elevation: 0,
        actions: [
          // daj na srodek 
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () {
              SharedService.logout(context);
            },
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      // in body run  _getCurrentPage() and  userProfile()
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index){
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Strona startowa",
            backgroundColor: Color.fromARGB(255, 90, 184, 208),
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: "Urządzenia",
            backgroundColor: Color.fromARGB(255, 90, 184, 208),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            label: "Bluetooth",
            backgroundColor: Color.fromARGB(255, 90, 184, 208),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Konfiguracja",
            backgroundColor: Color.fromARGB(255, 90, 184, 208),
          ),
        ],
      ),
    );
  }





Widget userProfile() {
    return FutureBuilder(
      
      future: APIService.getUserProfile(),
      builder: (
        
        BuildContext context,
        AsyncSnapshot<String> model,
      ) {
        if (model.hasData) {
          return Center(child: Text(model.data!));
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
