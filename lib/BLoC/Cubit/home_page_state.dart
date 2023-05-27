
import 'package:dhrubok_weather_app/Model/weather.dart';
import 'package:weather/weather.dart';

import '../../Model/WeatherModel.dart';

class DataListState{}

class DataListInitialState extends DataListState{}



class CurrentandForcastWeatherState extends DataListState{
  WeatherResponseModel weatherResponse;
  List<Weather> fiveDaysForcastWeather;
  List<MyWeather> fiveDaysForcastMyWeather;
  CurrentandForcastWeatherState(this.weatherResponse,{this.fiveDaysForcastWeather= const [], this.fiveDaysForcastMyWeather = const []});
}
