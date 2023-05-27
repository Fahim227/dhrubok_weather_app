class MyWeather {
  String? date;
  int? isForecast;
  String? areaName;
  double? temperatureCelsius;
  double? temperatureFahrenheit;
  String? weatherDescription;
  String? weatherIcon;
  int? humidity;
  int? pressure;
  int? cloudiness;
  double? windSpeed;

  MyWeather(
      {this.isForecast,
        this.areaName,
        this.temperatureCelsius,
        this.temperatureFahrenheit,
        this.weatherDescription,
        this.weatherIcon,
        this.humidity,
        this.pressure,
        this.cloudiness,
        this.windSpeed,
        this.date,
      });

  MyWeather.fromJson(Map<String, dynamic> json) {
    isForecast = json['isForecast'];
    areaName = json['area_name'];
    temperatureCelsius = json['temperature_celsius'];
    temperatureFahrenheit = json['temperature_fahrenheit'];
    weatherDescription = json['weatherDescription'];
    weatherIcon = json['weatherIcon'];
    humidity = json['humidity'];
    pressure = json['pressure'];
    cloudiness = json['cloudiness'];
    windSpeed = json['windSpeed'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isForecast'] = this.isForecast;
    data['area_name'] = this.areaName;
    data['temperature_celsius'] = this.temperatureCelsius;
    data['temperature_fahrenheit'] = this.temperatureFahrenheit;
    data['weatherDescription'] = this.weatherDescription;
    data['weatherIcon'] = this.weatherIcon;
    data['humidity'] = this.humidity;
    data['pressure'] = this.pressure;
    data['cloudiness'] = this.cloudiness;
    data['windSpeed'] = this.windSpeed;
    data['date'] = this.date;
    return data;
  }
}