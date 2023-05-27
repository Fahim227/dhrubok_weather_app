
import 'package:dhrubok_weather_app/Model/weather.dart';
import 'package:weather/weather.dart';

class WeatherResponseModel{
  bool? isSuccess;
  String? message;
  Weather? weather;
  MyWeather? myWeather;

  WeatherResponseModel(this.isSuccess, this.message, this.weather,{this.myWeather});
}
