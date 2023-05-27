import 'package:weather/weather.dart';

import '../Model/WeatherModel.dart';

class DataRepository{
  WeatherFactory? wf;
  DataRepository(){
    this.wf = new WeatherFactory("dfb8ddd31293ce788e4ddfd9b4010c76");
  }

  Future<List<Weather>> getFiveDaysForcastFromOnlineByLatLong(double lat, double lon) async {
    List<Weather> weatherForcast = await wf!.fiveDayForecastByLocation(lat, lon);
    return weatherForcast;
  }

  Future<WeatherResponseModel> getCurrentWeatherFromOnlineByLatLong(double lat, double lon) async {
    Weather weather = await wf!.currentWeatherByLocation(lat, lon);
    WeatherResponseModel weatherResponseModel = WeatherResponseModel(true,'Has Data', weather);
    return weatherResponseModel;
  }

  Future<WeatherResponseModel> getCurrentWeatherFromOnlineByCityName(String cityName) async {
    WeatherResponseModel weatherResponseModel = WeatherResponseModel(false,'No Weather Data',null);
    try{
       Weather weather = await wf!.currentWeatherByCityName(cityName);
       weatherResponseModel.weather = weather;
       weatherResponseModel.isSuccess = true;
    }
    catch(e){
       if (e.runtimeType.toString() == 'OpenWeatherAPIException'){
         print(" e.toString() =============== ${e.toString()}");
         weatherResponseModel.weather = null;
         weatherResponseModel.isSuccess = false;
         weatherResponseModel.message = "Please Enter a Valid City Name";
       }
    }
    // Weather weather = await wf!.currentWeatherByCityName(lat, lon);
    return weatherResponseModel;
  }
  Future<List<Weather>> getFiveDaysForcastFromOnlineByCityName(String cityName) async {
    List<Weather> weatherForcast = await wf!.fiveDayForecastByCityName(cityName);
    return weatherForcast;
  }

}