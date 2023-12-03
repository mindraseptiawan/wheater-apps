class WeatherData {
  final String cityName;
  final double temperature;
  final String weatherDescription;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.weatherDescription,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: (json['main']['temp'] - 273.15),
      weatherDescription: json['weather'][0]['description'],
    );
  }

  @override
  String toString() {
    return 'WeatherData{cityName: $cityName, temperature: $temperature, weatherDescription: $weatherDescription}';
  }
}
