
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dhrubok_weather_app/Model/WeatherModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

import '../../DataRepository/data_repo.dart';
import '../../DatabaseProvider/oflineDataBase.dart';
import '../../Model/weather.dart';
import 'home_page_state.dart';


class DataListCubit extends Cubit<DataListState>{

  final DataRepository _dataRepository;
  DataListCubit(this._dataRepository):super(DataListInitialState());


  void getCurrentAndForcastWeatherOnlineByCityName(String cityName) async {
    print("getCurrentAndForcastWeatherOnlineByCityName");
    WeatherResponseModel currentWeatherResponse =  await _dataRepository.getCurrentWeatherFromOnlineByCityName(cityName);
    List<Weather> forcastWeather = [];
    if (currentWeatherResponse.isSuccess!){
      forcastWeather =  await _dataRepository.getFiveDaysForcastFromOnlineByCityName(cityName);
    }
    else{
      Position position = await _determinePosition();
      currentWeatherResponse =  await _dataRepository.getCurrentWeatherFromOnlineByLatLong(position.latitude,position.longitude);
      currentWeatherResponse.isSuccess =false;
      currentWeatherResponse.message ="Please Enter a Valid City Name";
      forcastWeather =  await _dataRepository.getFiveDaysForcastFromOnlineByLatLong(position.latitude,position.longitude);
    }

    int code = await DatabaseHelper.instance.insertWeatherData(currentWeatherResponse,forcastWeather);
    print("Code ========== $code");
    emit(CurrentandForcastWeatherState(currentWeatherResponse,fiveDaysForcastWeather : forcastWeather));
  }

  void checkConnectivity() async{
    if (await AppHelper.isInternetAvailable()){
      getCurrentAndForcastWeatherOnlineByLatLong();
    }
    else{
      getCurrentAndForcastWeatherOffline();
    }
  }

  void getCurrentAndForcastWeatherOnlineByLatLong() async {
    print("getCurrentAndForcastWeatherOnlineByLatLong");
    Position position = await _determinePosition();
    WeatherResponseModel currentResponseWeather =  await _dataRepository.getCurrentWeatherFromOnlineByLatLong(position.latitude,position.longitude);
    List<Weather> forcastWeather =  await _dataRepository.getFiveDaysForcastFromOnlineByLatLong(position.latitude,position.longitude);
    int code = await DatabaseHelper.instance.insertWeatherData(currentResponseWeather,forcastWeather);
    print("Code ========== $code");
    emit(CurrentandForcastWeatherState(currentResponseWeather,fiveDaysForcastWeather: forcastWeather));
  }

  void getCurrentAndForcastWeatherOffline() async {
    WeatherResponseModel currentResponseWeather = await DatabaseHelper.instance.getCurrentWeather();
    List<MyWeather> forecastWeather =   await DatabaseHelper.instance.getForecastWeather();
    print(currentResponseWeather.myWeather!.weatherDescription!);
    emit(CurrentandForcastWeatherState(currentResponseWeather,fiveDaysForcastMyWeather: forecastWeather));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }


}

class AppHelper{
  static Future<bool> isInternetAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}