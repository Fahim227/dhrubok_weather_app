import 'dart:ui';

import 'package:dhrubok_weather_app/BLoC/Cubit/home_page_state.dart';
import 'package:dhrubok_weather_app/Model/weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';
import '../BLoC/Cubit/home_page_cubit.dart';
import '../DataRepository/data_repo.dart';
import '../DatabaseProvider/oflineDataBase.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String iconNetworkImg = "https://openweathermap.org/img/wn/{icon}@2x.png";
  TextEditingController cityNameController = TextEditingController();

  DatabaseHelper? DBHelper;
  Database? _dataBase;

  void _createDB() async {
    DBHelper = await DatabaseHelper.instance;
    _dataBase = await DBHelper!.database;
    print(await _dataBase!.getVersion());
  }

  @override
  void initState() {
    super.initState();
    _createDB();
  }

  @override
  Widget build(BuildContext context) {
    List<Weather> forcastWeather = [];
    List<MyWeather> forcastMyWeather = [];
    Weather? currentWeather;
    MyWeather? currentMyWeather;
    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Weather App'),
        backgroundColor: Colors.deepPurple,

      ),
      body: BlocProvider<DataListCubit>(
        create: (context) => DataListCubit(DataRepository()),
        child: BlocConsumer<DataListCubit, DataListState>(
            listener: (context, state) {

          if (state is CurrentandForcastWeatherState) {
            if ((state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length != 0)
            {
              currentWeather =
                  (state as CurrentandForcastWeatherState).weatherResponse.weather;
              print(currentWeather!.toJson());
              forcastWeather =
                  (state as CurrentandForcastWeatherState).fiveDaysForcastWeather;
            }
            if ((state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather.length != 0)
            {
              currentMyWeather =
                  (state as CurrentandForcastWeatherState).weatherResponse.myWeather;
              forcastMyWeather =
                  (state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather;
            }

          }
        }, builder: (context, state) {
          if (state is DataListInitialState) {
            context.read<DataListCubit>().checkConnectivity();
          }
          if (state is CurrentandForcastWeatherState) {
            Weather? currentWeather =
                (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length != 0 ?(state as CurrentandForcastWeatherState).weatherResponse.weather! : null;
            MyWeather? currentMyWeather =
            (state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather.length != 0 ?(state as CurrentandForcastWeatherState).weatherResponse.myWeather! : null;
            print("forcastMyWeather =========== ${(state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather.length}");
            // List<Weather>? forcastWeather =
            //     (state as CurrentandForcastWeatherState).fiveDaysForcastWeather;
            return Center(
              child: Container(
                height: size.height,
                width: size.height,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length==0 ? Container() : Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01,
                                horizontal: size.width * 0.05,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Visibility(
                                    visible: true,
                                      child:Expanded(
                                        child: Container(
                                          margin: EdgeInsets.all(15),
                                          
                                          child: TextFormField(
                                            onChanged: null,
                                            onTap: null,
                                            // validator: (value){
                                            //   if ((state as CurrentandForcastWeatherState).weatherResponse.isSuccess == false){
                                            //     return (state as CurrentandForcastWeatherState).weatherResponse.message;
                                            //   }
                                            // },

                                            controller: cityNameController,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            decoration: InputDecoration(
                                              focusColor: Colors.white,
                                              //add prefix icon
                                              prefixIcon: Icon(
                                                Icons.location_city,
                                                color: Colors.grey,
                                              ),

                                              errorText: (state as CurrentandForcastWeatherState).weatherResponse.isSuccess == false ? (state as CurrentandForcastWeatherState).weatherResponse.message : null,

                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),

                                              // focusedBorder: OutlineInputBorder(
                                              //   borderSide:
                                              //   const BorderSide(color: Colors.blue, width: 1.0),
                                              //   borderRadius: BorderRadius.circular(10.0),
                                              // ),
                                              fillColor: Colors.grey,

                                              hintText: "City Name",

                                              //make hint text
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                fontFamily: "verdana_regular",
                                                fontWeight: FontWeight.w400,
                                              ),

                                            ),
                                          ),
                                        ),
                                      ),),
                                  IconButton(
                                    icon:  Icon(FontAwesomeIcons.search),
                                    onPressed: (){
                                      context.read<DataListCubit>().getCurrentAndForcastWeatherOnlineByCityName(cityNameController.text.toString());

                                    },

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
                                  (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ?  currentMyWeather!.areaName!.toString() : currentWeather!.areaName!.toString(),
                                  style: GoogleFonts.questrial(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
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
                                  'Today', //day
                                  style: GoogleFonts.questrial(
                                    color: isDarkMode
                                        ? Colors.white54
                                        : Colors.black54,
                                    fontSize: size.height * 0.035,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: size.height * 0.03,
                                          ),
                                          child: Align(
                                            child: Text(
                                              '${(state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ?  currentMyWeather!.temperatureCelsius : double.parse(currentWeather!.temperature!.toString().split(' ').first)}˚C',
                                              // curent temperature
                                              style: GoogleFonts.questrial(
                                                color: Colors.deepPurple,
                                                fontSize: size.height * 0.10,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: size.height * 0.01,
                                          ),
                                          child: Align(
                                            child: Text(
                                              '${(state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length==0 ?  currentMyWeather!.temperatureFahrenheit : ((double.parse(currentWeather!.temperature!.toString().split(' ').first) * 9) / 5) + 32}˚F',

                                              style: GoogleFonts.questrial(
                                                color: Colors.deepPurple,
                                                fontSize: size.height * 0.10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.25),
                                      child: Divider(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: size.height * 0.005,
                                      ),
                                      child: Align(
                                        child: Text(
                                          '${(state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length ==0 ?  currentMyWeather!.weatherDescription: currentWeather!.weatherDescription!}', // weather
                                          style: GoogleFonts.questrial(
                                            color: isDarkMode
                                                ? Colors.white54
                                                : Colors.black54,
                                            fontSize: size.height * 0.03,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                buildForecastToday(
                                    "Now",
                                    //hour
                                    (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length ==0 ? currentMyWeather!.temperatureCelsius!.toInt() : double.parse(currentWeather!.temperature!.toString().split(' ').first).toInt(),
                                    //temperature
                                    (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length ==0 ? currentMyWeather!.windSpeed! : currentWeather!.windSpeed!,
                                    //wind (km/h)
                                    0,
                                    //rain chance (%)
                                    (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length ==0 ? currentMyWeather!.weatherIcon! : currentWeather!.weatherIcon!,
                                    //weather icon
                                    size,
                                    isDarkMode,
                                    (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length ==0 ? currentMyWeather!.humidity!.toDouble() : currentWeather!.humidity!,
                                    (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length ==0 ? currentMyWeather!.pressure!.toDouble() : currentWeather!.pressure!,
                                    (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length ==0 ? currentMyWeather!.cloudiness!.toDouble() : currentWeather!.cloudiness!,'','',forcastWeather.length == 0),
                              ],
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
                                          '5-day Forecast',
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
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(size.width * 0.005),
                                      child: SizedBox(
                                        width: size.width,
                                        height: size.height/2.5,
                                        child: Row(
                                          children: [
                                            //TODO: change weather forecast from local to api get

                                            Expanded(
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  physics: AlwaysScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ? (state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather.length : (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    print(index);
                                                    return buildForecastToday(
                                                        "${DateFormat('dd-MM').format((state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ? DateTime.parse((state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather[index].date!) : (state as CurrentandForcastWeatherState).fiveDaysForcastWeather[index].date!)}",
                                                        (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ? (state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather[index].temperatureCelsius!.round() :(state as CurrentandForcastWeatherState).fiveDaysForcastWeather[index].temperature!.celsius!.round(),
                                                        (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ? (state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather[index].windSpeed! : (state as CurrentandForcastWeatherState).fiveDaysForcastWeather[index].windSpeed!,
                                                        0,
                                                        (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ? '' : (state as CurrentandForcastWeatherState).fiveDaysForcastWeather[index].weatherIcon!,
                                                        size,
                                                        isDarkMode,
                                                        (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ? (state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather[index].humidity!.toDouble() : (state as CurrentandForcastWeatherState).fiveDaysForcastWeather[index].humidity!,
                                                        (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ? (state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather[index].pressure!.toDouble(): (state as CurrentandForcastWeatherState).fiveDaysForcastWeather[index].pressure!,
                                                        (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ? (state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather[index].cloudiness!.toDouble() : (state as CurrentandForcastWeatherState).fiveDaysForcastWeather[index].cloudiness!,
                                                        "${DateFormat.Hm().format((state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ? DateTime.parse((state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather[index].date!) : (state as CurrentandForcastWeatherState).fiveDaysForcastWeather[index].date!)}",
                                                        (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0 ? (state as CurrentandForcastWeatherState).fiveDaysForcastMyWeather[index].weatherDescription! : (state as CurrentandForcastWeatherState).fiveDaysForcastWeather[index].weatherDescription!,
                                                        (state as CurrentandForcastWeatherState).fiveDaysForcastWeather.length == 0
                                                    );
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(
            child: Text("Fetching....",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
          );
        }),
      ),
    );
  }

  Widget buildForecastTodayOld(String time, int temp, int wind, int rainChance,
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
                  FontAwesomeIcons.wind,
                  color: Colors.grey,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$wind km/h',
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
                  FontAwesomeIcons.umbrella,
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

  Widget buildForecastToday(
      String time,
      int temp,
      double wind,
      int rainChance,
      String weatherIcon,
      Size size,
      bool isDarkMode,
      double humidity,
      double wind_pressure,
      double cloudiness,String t,String desc,bool isOffline) {

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
              CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.blue[200],
                backgroundImage: isOffline == true ? Image.asset("assets/image/03d.png").image : NetworkImage(
                  iconNetworkImg.replaceAll('{icon}', weatherIcon),
                ),
              ),

            ],
          ),
          Text(
            '$cloudiness %',
            style: GoogleFonts.questrial(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.height * 0.025,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.005,
                ),
                child: FaIcon(
                  // wind pressure
                  Icons.wind_power_rounded,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$wind_pressure hPa',
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
                  FontAwesomeIcons.wind,
                  color: Colors.grey,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$wind km/h',
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
                  Icons.water_drop_outlined,
                  color: Colors.blue,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$humidity %',
            style: GoogleFonts.questrial(
              color: Colors.blue,
              fontSize: size.height * 0.02,
            ),
          ),
          SizedBox(height: 10.0,),
          Text(
            '$desc',
            style: GoogleFonts.questrial(
              color: Colors.black,
              fontSize: size.height * 0.02,
            ),
          ),
          SizedBox(height: 10.0,),
          Text(
            '$t',
            style: GoogleFonts.questrial(
              color: Colors.black,
              fontSize: size.height * 0.02,
            ),
          )
        ],
      ),
    );
  }

}
