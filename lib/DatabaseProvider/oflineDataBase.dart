
import 'package:dhrubok_weather_app/Model/WeatherModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:weather/weather.dart';

import '../Model/weather.dart';

class DatabaseHelper {
  // Make a Singleton instance of DatabaseHelper
  // the singleton pattern is a software design pattern that,
  // restricts the instantiation of a class to one "single" instance.
  // This is useful when exactly one object is needed to coordinate actions across the system.
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Initialize the database name
  // and define a Database instance
  static String dbName = 'Database.db';
  static Database? _database;
  static int? databaseVersion = 1;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    String directoryPath = await getDatabasesPath();
    String path = join(directoryPath, DatabaseHelper.dbName);
    return await openDatabase(path, version: databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: (Database? db, int oldVersion, int newVersion) {
          print(newVersion);
          if (oldVersion < newVersion) {
          }
        });
  }


  void _createDatabase(Database db, int version) async {
    await db.execute('CREATE TABLE Weather (id INTEGER PRIMARY KEY AUTOINCREMENT,'
        ' isForecast INTEGER,'
        ' date TEXT,'
        ' area_name TEXT,'
        ' temperature_celsius REAL,'
        ' temperature_fahrenheit REAL,'
        ' weatherDescription TEXT,'
        ' weatherIcon TEXT,'
        ' humidity INTEGER,'
        ' pressure INTEGER,'
        ' cloudiness INTEGER,'
        ' windSpeed REAL )');
  }

  Future<int> insertWeatherData(WeatherResponseModel weatherResponseModel, List<Weather> forecastWeather) async {
    print("insertWeatherData  ===========");
    Database? db = await instance.database;
    DatabaseHelper.deleteAll('Weather');
    Map<String, dynamic> jsonData = getWeatherObjToJSON(weatherResponseModel.weather!.toJson()!,0);
    print("offlien data ============= ${weatherResponseModel.weather!.toJson()!}");

    print(await db!.query("Weather"));
    bool isInsertedCurrentWeather = false;
    for (Weather w in forecastWeather){
      if (!isInsertedCurrentWeather){
        await db.insert('Weather',jsonData);
        isInsertedCurrentWeather = true;
      }
      Map<String, dynamic> forecastJsonData = getWeatherObjToJSON(w.toJson()!, 1);
      await db.insert('Weather',forecastJsonData);
    }
    // print("type =========== $type_id");
    print(await db.query("Weather"));
    return 1;
  }

  Future<WeatherResponseModel> getCurrentWeather() async {
    WeatherResponseModel weatherResponseModel = WeatherResponseModel(false,'',null);
    Database? db = await instance.database;

    List<Map<String, dynamic>> map  = await db!.rawQuery("SELECT * FROM Weather WHERE isForecast = 0");
    print("map leng ====== ${map.length}");
    List<MyWeather> allWeather = map.map((e) => MyWeather.fromJson(e)).toList();
    print("leng ====== ${allWeather.length}");
    if (allWeather.length >0){
      weatherResponseModel.myWeather = allWeather[0];
    }
    return weatherResponseModel;
  }

  Future<List<MyWeather>> getForecastWeather() async {
    Database? db = await instance.database;
    List<Map<String, dynamic>> map  = await db!.rawQuery("SELECT * FROM Weather WHERE isForecast = 1");
    print("map leng ====== ${map.length}");
    List<MyWeather> allWeather = map.map((e){
      return MyWeather.fromJson(e);
    }).toList();

    return allWeather;
  }


  Map<String,dynamic> getWeatherObjToJSON(Map<String,dynamic> weatherJsonData,int isForecast){
    Map<String, dynamic> jsonData = {};
    jsonData["isForecast"] = isForecast;
    int millis = weatherJsonData["dt"] * 1000;
    DateTime date_time =  DateTime.fromMillisecondsSinceEpoch(millis);
    jsonData["date"] = date_time.toString();
    jsonData["area_name"] = weatherJsonData['name'].toString();
    double kelving = weatherJsonData['main']['temp'].toDouble();
    double celcius = kelving - 273.15;
    double fahrenheit = kelving * (9 / 5) - 459.67;
    jsonData ["temperature_celsius"] = celcius.round().toDouble();
    jsonData ["temperature_fahrenheit"] = fahrenheit.round().toDouble() ;
    jsonData ["weatherDescription"] =  weatherJsonData['weather'][0]['description'].toString();
    jsonData ["weatherIcon"] =  weatherJsonData['weather'][0]['icon'].toString().replaceAll(' ', '');
    jsonData ["humidity"] =  int.parse(weatherJsonData['main']['humidity'].toString());
    jsonData ["pressure"] =  int.parse(weatherJsonData['main']['pressure'].toString());
    jsonData ["cloudiness"] =  int.parse(weatherJsonData['clouds']['all'].toString());
    jsonData ["windSpeed"] =  double.parse(weatherJsonData['wind']['speed'].toString());
    return jsonData;
  }



  static Future<int> deleteAll(String tableName) async {
    int result = 0;
    try {
      var dbClient = await _database;
      result = await dbClient!.delete(tableName);
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  //

  //
  // Future<List<CVModel> > getAllCV() async{
  //   // String query = 'INSERT INTO ${CustomerTypeFields.tableName} (name,type) VALUES(${customerType.name},${customerType.type});';
  //   Database? db = await instance.database;
  //   List<Map<String, dynamic>> map  = await db!.rawQuery("SELECT * FROM ${CVModelFields.tableName}");
  //   List<CVModel> allCVS = map.map((e) => CVModel.fromMap(e)).toList();
  //   return allCVS;
  // }




}