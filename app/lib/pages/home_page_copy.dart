import 'dart:convert';
import 'dart:developer';
import 'dart:io';


import 'package:IOT_APP_KONCOWA_WERSJA/pages/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';



import "package:flutter/services.dart" show rootBundle;

import 'configuration.dart';


class HomePage_temperature extends StatefulWidget {
  



  

  

  // modify constructor to accept a parameter of type String and assign it to a field of the same type in the class
  // final String title;
  // HomePage_temperature({Key key, this.title}) : super(key: key);
  // HomePage_temperature({Key key}) : super(key: key); 
  final String text;

  const HomePage_temperature({Key? key, required this.text }) : super(key: key);

  
  
  @override
  _HomePage_temperatureState createState() => _HomePage_temperatureState();
}

class _HomePage_temperatureState extends State<HomePage_temperature> {



double wilgotnosc_api = 0.0;
double temperatura_api = 0.0;
double cisnienie_api = 0.0;
double voltage_api = 0.0;

double srednia_tygodniowa_temperatura = 23.6;
double srednia_tygodniowa_wilgotnosc = 45.2;
double srednia_tygodniowa_cisnienie = 1002.1;

double srednia_miesieczna_temperatura = 22.8;
double srednia_miesieczna_wilgotnosc = 40.1;
double srednia_miesieczna_cisnienie = 1014.3;


List<double> last_six_days_wilgotnosc = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
List<double> last_six_days_temperatura = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
List<double> last_six_days_cisnienie = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
List<String> last_six_days_date = ["0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0"];

// create structure to store SalesData type objects 
List<SalesData> chartData = [];



// create double array  last_seven_days_wilgotnosc with empty values


Future<void> _fetchData(topic) async {
    const apiUrl = 'http://192.109.244.131:3000/wilgotnosc'; // 192.109.244.131
    //const apiUrl = 'http://localhost:3000/wilgotnosc';

    HttpClient client = HttpClient();
    client.autoUncompress = true;

    final HttpClientRequest request = await client.getUrl(Uri.parse(apiUrl));
    request.headers
        .set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    final HttpClientResponse response = await request.close();

    final String content = await response.transform(utf8.decoder).join();
    Map<String, dynamic> data = json.decode(content);
    String data_string = data['data'].toString();

    int counter = 0;
    last_six_days_wilgotnosc.clear(); 
    double last_value_double = 0.0;
    for (var i = data['data'].length -1 ; i > 0 ; i--) {

      String temperatura_string = data['data'][i]['wilgotnosc_value'].toString();
      // convert string to double
      double temperatura_double = double.parse(temperatura_string);
      // add last value to array

      if( data['data'][i]['topic'].toString() == topic){
        last_six_days_wilgotnosc.add(temperatura_double);
        if(counter == 0) last_value_double = temperatura_double;
        counter++;
      }


      if (counter == 7) {
        break;
      }
    }

    setState(() {
      wilgotnosc_api = last_value_double;
    });
}

Future<void> temperature(topic) async {
    const apiUrl = 'http://192.109.244.131:3000/temperature';
    //const apiUrl = 'http://localhost:3000/temperature';

    HttpClient client = HttpClient();
    client.autoUncompress = true;

    final HttpClientRequest request = await client.getUrl(Uri.parse(apiUrl));
    request.headers
        .set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    final HttpClientResponse response = await request.close();

    final String content = await response.transform(utf8.decoder).join();
    Map<String, dynamic> data = json.decode(content);

    int counter = 0;
    last_six_days_date.clear();
    last_six_days_temperatura.clear();


    last_six_days_temperatura.clear();
    last_six_days_date.clear();

    String data_string = data['data'].toString();
    double last_value_double = 0.0;
    for (var i = data['data'].length -1 ; i > 0 ; i--) {

      String temperatura_string = data['data'][i]['temperatura_value'].toString();
      // convert string to double
      double temperatura_double = double.parse(temperatura_string);
      // add last value to array

      if( data['data'][i]['topic'].toString() == topic){
        last_six_days_temperatura.add(temperatura_double);
        last_six_days_date.add(data['data'][i]['data'].toString());
        if(counter == 0) last_value_double = temperatura_double;
        counter++;
      }


      if (counter == 7) {
        break;
      }
    }

    // clear chartData
    chartData.clear();
    for (var i = data['data'].length -1 ; i > 0 ; i--) {
      if(data['data'][i]['topic'] == topic) {

        String temperatura_string = data['data'][i]['temperatura_value'].toString();
      // convert string to double
      double temperatura_double = double.parse(temperatura_string);
      // add last value to array

      String data_string = data['data'][i]['data'].toString();

      print(data_string);

      // actual number of day
      int day = DateTime.now().day;
      // actual number of month
      int month = DateTime.now().month;
      // actual number of year

      // format 11:22 01/23/23 to get day and month and hour&minute
      String day_string = data_string.substring(9, 11);
      String month_string = data_string.substring(6, 8);
      String hourandminute_string = data_string.substring(0, 5);

      // if 0 on data_string[] delete it
      if (month_string[0] == '0') {
        month_string = month_string.substring(1, 2);
      }
      print("day_string: "+ day_string + " month_string: " + month_string);
      print("day_string: "+ day.toString() + " month_string: " + month.toString());

      // if day and month is the same as actual day and month add to array
      if (day_string == day.toString() && month_string == month.toString()) {
        // add to chartData 
        chartData.add(SalesData(hourandminute_string,temperatura_double));
      }
      else{
        break;
      }

      }
    }
    setState(() {
      temperatura_api = last_value_double;
    });
}

Future<void> cisnienie_m(topic) async {
    const apiUrl = 'http://192.109.244.131:3000/cisnienie';
    //const apiUrl = 'http://localhost:3000/cisnienie';

    HttpClient client = HttpClient();
    client.autoUncompress = true;

    final HttpClientRequest request = await client.getUrl(Uri.parse(apiUrl));
    request.headers
        .set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    final HttpClientResponse response = await request.close();

    final String content = await response.transform(utf8.decoder).join();
    Map<String, dynamic> data = json.decode(content);
    String data_string = data['data'].toString();


    int counter = 0;
    last_six_days_cisnienie.clear(); 
    double last_value_double = 0.0;
    for (var i = data['data'].length -1 ; i > 0 ; i--) {

      String temperatura_string = data['data'][i]['cisnienie_value'].toString();
      // convert string to double
      double temperatura_double = double.parse(temperatura_string);
      // add last value to array

      if( data['data'][i]['topic'].toString() == topic){
        last_six_days_cisnienie.add(temperatura_double);
        if(counter == 0) last_value_double = temperatura_double;
        counter++;
      }


      if (counter == 7) {
        break;
      }
    }

 
    setState(() {
      cisnienie_api = last_value_double;
    });
}




  @override
  Widget build(BuildContext context) {

  print(widget.text);  // TOPIC

// do tych metod dodac zeby sprawdzaly czy mac jest taki sam jak widget.text
Future.delayed(Duration(seconds: 10), () {
       // wilgotnosc
      _fetchData(widget.text);
      // temperatura
      temperature(widget.text);
      // cisnienie
      cisnienie_m(widget.text);


    });

    // temperatura


    // cisnienie



    String cityName = "IoT Application"; //city name
    double currTemp = temperatura_api; // current temperature
    int maxTemp = 20; // today max temperature
    int minTemp = 2; // today min temperature

    double cisnienie = cisnienie_api; // cisnienie
    double wilgotnosc =  wilgotnosc_api ; // wilgotnosc


    int temperature_month = 20; // temperature month
    int cisnienie_month = 1000; // cisnienie month
    int wilgotnosc_month = 100; // wilgotnosc month

    int temperatur_week = 20; // temperature week
    int cisnienie_week = 1000; // cisnienie week
    int wilgotnosc_week = 100; // wilgotnosc week



    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;


    
    return Scaffold(
      body: Center(
        child: Container(
          height: size.height,
          width: size.height,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Color.fromARGB(115, 207, 221, 232),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.01,
                          horizontal: size.width * 0.05,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // after click on icon, route to configure device
                            GestureDetector(
                              onTap: () {
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      // refresh page after click on icon
                                      builder: (context) => FormScreen()),//MyHomePage(title: 'IOT APP',)),
                                );
                              },
                              child: FaIcon(
                                FontAwesomeIcons.cog,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Align(
                              child: Text(
                                'IoT App', //TODO: change app name
                                style: GoogleFonts.questrial(
                                  color: isDarkMode
                                      ? Colors.white
                                      : const Color(0xff1D1617),
                                  fontSize: size.height * 0.02,
                                ),
                              ),
                            ),
                            FaIcon(
                              FontAwesomeIcons.plusCircle,
                              color: isDarkMode ? Color.fromARGB(255, 238, 245, 248) : Colors.black,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.03,
                        ),
                        child: Align(
                          child: Text(
                            cityName,
                            style: GoogleFonts.questrial(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: size.height * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.005,
                        ),
                        child: Align(
                          child: Text(
                            'Teraz', //day
                            style: GoogleFonts.questrial(
                              color:
                                  isDarkMode ? Color.fromARGB(136, 24, 246, 20) : Colors.black54,
                              fontSize: size.height * 0.035
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.03,
                        ),
                        child: Align(
                          child: Text(
                            '$currTemp °C', //curent temperature
                            style: GoogleFonts.questrial(
                              color: currTemp <= 0
                                  ? Colors.blue
                                  : currTemp > 0 && currTemp <= 15
                                      ? Colors.indigo
                                      : currTemp > 15 && currTemp < 30
                                          ? Colors.deepPurple
                                          : Colors.pink,
                              fontSize: size.height * 0.13,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.25),
                        child: Divider(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.005,
                        ),
                        child: Align(
                          child: Text(
                            ///////////////////////////////////////////////////////
                            ///
                            ///
                            ///
                            'Wilgotność | Ciśnienie', // weather
                            style: GoogleFonts.questrial(
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black54,
                              fontSize: size.height * 0.03,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.03,
                          bottom: size.height * 0.01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          /////////////////////////////////////////// ZMIANA CISNIENIA I WILGOTNOSCI
                          children: [
                            Text(
                              '$wilgotnosc %', // min temperature
                              style: GoogleFonts.questrial(
                                color: wilgotnosc <= 0
                                    ? Colors.blue
                                    : wilgotnosc > 0 && wilgotnosc <= 15
                                        ? Colors.indigo
                                        : wilgotnosc > 15 && wilgotnosc < 30
                                            ? Colors.deepPurple
                                            : Color.fromARGB(255, 151, 242, 240),
                                fontSize: size.height * 0.03,
                              ),
                            ),
                            Text(
                              ' / ',
                              style: GoogleFonts.questrial(
                                color: isDarkMode
                                    ? Colors.white54
                                    : Colors.black54,
                                fontSize: size.height * 0.03,
                              ),
                            ),
                            Text(
                              '$cisnienie hPa', //max temperature
                              style: GoogleFonts.questrial(
                                color: cisnienie <= 0
                                    ? Colors.blue
                                    : cisnienie > 0 && cisnienie <= 15
                                        ? Colors.indigo
                                        : cisnienie > 15 && cisnienie < 30
                                            ? Colors.deepPurple
                                            : Colors.pink,
                                fontSize: size.height * 0.03,
                              ),
                            ),
                            //////////////////////////////////
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: size.height * 0.01,
                                    left: size.width * 0.03,
                                  ),
                                  child: Text(
                                    'Wcześniejsze pomiary w godzinach',
                                    style: GoogleFonts.questrial(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: size.height * 0.025,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(size.width * 0.005),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      //TODO: change weather forecast from local to api get

                                      ///////////////////////////////////////////////////////
                                      ///
                                      buildForecastToday(
                                        last_six_days_date[0],
                                        last_six_days_temperatura[0],
                                        last_six_days_cisnienie[0],
                                        last_six_days_wilgotnosc[0],
                                        FontAwesomeIcons.cloud,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildForecastToday(
                                        last_six_days_date[1],
                                        last_six_days_temperatura[1],
                                        last_six_days_cisnienie[1],
                                        last_six_days_wilgotnosc[1],
                                        FontAwesomeIcons.cloud,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildForecastToday(
                                        last_six_days_date[2],
                                        last_six_days_temperatura[2],
                                        last_six_days_cisnienie[2],
                                        last_six_days_wilgotnosc[2],
                                        FontAwesomeIcons.cloud,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildForecastToday(
                                        last_six_days_date[3],
                                        last_six_days_temperatura[3],
                                        last_six_days_cisnienie[3],
                                        last_six_days_wilgotnosc[3],
                                        FontAwesomeIcons.cloud,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildForecastToday(
                                        last_six_days_date[4],
                                        last_six_days_temperatura[4],
                                        last_six_days_cisnienie[4],
                                        last_six_days_wilgotnosc[4],
                                        FontAwesomeIcons.cloud,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildForecastToday(
                                        last_six_days_date[5], //hour
                                        last_six_days_temperatura[5], //temperature  // current temperature
                                        last_six_days_cisnienie[5], //wind (km/h)
                                        last_six_days_wilgotnosc[5], //rain chance (%)
                                        FontAwesomeIcons.cloud, //weather icon
                                        size,
                                        isDarkMode,
                                      ),

                                      // FontAwesomeIcons.cloud
                                      // FontAwesomeIcons.sun
                                      // FontAwesomeIcons.snowflake

                                      
                                      // 
                                      // FontAwesomeIcons.cloudMoon
                                      // FontAwesomeIcons.cloudSun
                                      // FontAwesomeIcons.cloudRain
                                      // FontAwesomeIcons.cloudShowersHeavy
                                      // FontAwesomeIcons.moon
                                      //////////////////////////////////////////////////////
                                      ///

                                      ////////////////////////////////////
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.02,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Colors.white.withOpacity(0.05),
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: size.height * 0.02,
                                    left: size.width * 0.03,
                                  ),
                                  child: Text(
                                    'Średnie pomiary:',
                                    style: GoogleFonts.questrial(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: size.height * 0.025,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              Padding(
                                padding: EdgeInsets.all(size.width * 0.005),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                        buildForecastToday(
                                        "Miesiac",
                                        srednia_miesieczna_temperatura,
                                        srednia_miesieczna_cisnienie,
                                        srednia_miesieczna_wilgotnosc,
                                        FontAwesomeIcons.cloud,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildForecastToday(
                                        "Tydzien",
                                        srednia_tygodniowa_temperatura,
                                        srednia_tygodniowa_cisnienie,
                                        srednia_tygodniowa_wilgotnosc,
                                        FontAwesomeIcons.sun,
                                        size,
                                        isDarkMode,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),








                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.02,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Colors.white.withOpacity(0.05),
                          ),
                          

          child: SfCartesianChart(

            primaryXAxis: CategoryAxis(),
            // Chart title
            title: ChartTitle(text: 'Wyniki Temperatury w ciagu 24h'),
            // Enable legend
            legend: Legend(isVisible: true),
            // Enable tooltip
            tooltipBehavior: _tooltipBehavior,

            series: <LineSeries<SalesData, String>>[
              LineSeries<SalesData, String>(
                dataSource:  chartData,
                xValueMapper: (SalesData sales, _) => sales.hour,
                yValueMapper: (SalesData sales, _) => sales.temperatture,
                // Enable data label
                dataLabelSettings: DataLabelSettings(isVisible: true)
              )
            ]
          )

                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


late TooltipBehavior _tooltipBehavior;

@override
void initState(){
  _tooltipBehavior = TooltipBehavior(enable: true);

  String topic_val="";
  // assign topic from constructor to topic_val

  print("topic_val: " + topic_val);
  
  super.initState();
  _fetchData(widget.text);
  temperature(widget.text);
  cisnienie_m(widget.text);
}

  Widget buildForecastToday(String time, double temp, double wind, double rainChance,
      IconData weatherIcon, size, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.025),
      child: Column(
        children: [
          Text(
            time,
            style: GoogleFonts.questrial(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.height * 0.02,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.005,
                ),
                child: FaIcon(
                  weatherIcon,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$temp˚C',
            style: GoogleFonts.questrial(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.height * 0.025,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                ),
                child: FaIcon(
                  //cisnienie
                  FontAwesomeIcons.gaugeSimple,
                  color: Colors.grey,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$wind hPa',
            style: GoogleFonts.questrial(
              color: Colors.grey,
              fontSize: size.height * 0.02,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                ),
                child: FaIcon(
                  FontAwesomeIcons.droplet,
                  color: Colors.blue,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$rainChance %',
            style: GoogleFonts.questrial(
              color: Colors.blue,
              fontSize: size.height * 0.02,
            ),
          ),
          
        ],
        
      ),
    );
  }
}

class SalesData {
    SalesData(this.hour, this.temperatture);
    final String hour;
    final double temperatture;
}
