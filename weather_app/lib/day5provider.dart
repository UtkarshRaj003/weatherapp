import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentWeather;
  List<Map<String, dynamic>> _hourlyForecast = [];
  Map<String, dynamic>? _tomorrowForecast;
  Map<String, dynamic>? _aqiData; // ✅ AQI Data
  bool _loading = false;
  double? _uvIndex;

  Map<String, dynamic>? get weather => _currentWeather;
  List<Map<String, dynamic>> get hourlyForecast => _hourlyForecast;
  Map<String, dynamic>? get tomorrowForecast => _tomorrowForecast;
  Map<String, dynamic>? get aqi => _aqiData; // ✅ getter for AQI
  bool get loading => _loading;
  double? get uvIndex => _uvIndex;

  final String _apiKey = "366308bddf15e648a41c2f2091761989";

  /// ✅ Fetch Current Weather
  Future<void> fetchWeather(String query) async {
    _loading = true;
    notifyListeners();

    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$query&appid=$_apiKey&units=metric"));

    if (response.statusCode == 200) {
      _currentWeather = json.decode(response.body);
    } else {
      _currentWeather = null;
    }

    _loading = false;
    notifyListeners();
  }

  /// ✅ Fetch Forecast (Hourly + Tomorrow)
  Future<void> fetchForecast(String query) async {
    _loading = true;
    notifyListeners();

    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=$query&appid=$_apiKey&units=metric"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List forecastList = data['list'];

      // 🔹 Hourly Forecast (6 slots only)
      _hourlyForecast = forecastList.take(9).map<Map<String, dynamic>>((item) {
        final time = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        return {
          "time": DateFormat.Hm().format(time),
          "temp": item['main']['temp'].round().toString() + "°",
          "icon": item['weather'][0]['icon'],
        };
      }).toList();

      // 🔹 Tomorrow Forecast (24h baad ka data, approx index 8)
      final tomorrowData = forecastList[8];
      _tomorrowForecast = {
        "date": DateFormat("EEEE").format(
            DateTime.fromMillisecondsSinceEpoch(tomorrowData['dt'] * 1000)),
        "temp_min": tomorrowData['main']['temp_min'].round(),
        "temp_max": tomorrowData['main']['temp_max'].round(),
        "description": tomorrowData['weather'][0]['description'],
        "icon": tomorrowData['weather'][0]['icon'],
      };
    } else {
      _hourlyForecast = [];
      _tomorrowForecast = null;
    }

    _loading = false;
    notifyListeners();
  }

  /// ✅ Dono ek sath fetch (Weather + Forecast + AQI)
  Future<void> fetchAll(String query) async {
    await fetchWeather(query);
    await fetchForecast(query);
  }
}
