import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:weather_app/models/current_response_model.dart';
import 'package:weather_app/models/forecast_response_model.dart';
import 'package:weather_app/utils/constants.dart';

class WeatherProvider extends ChangeNotifier {
  CurrentResponseModel? currentResponseModel;
  ForecastResponseModel? forecastResponseModel;

  double latitude = 0, longitude = 0;

  String unit = 'metric';

// 2ta not null hole  return korbe true r data chole asle notifylistner call hobe abong data update pabo
  // hasDataLoaded er upor nirvor kore amra weatherpage e ki data show korbo ta nirvor korbe
  bool get hasDataLoaded =>
      currentResponseModel != null && forecastResponseModel != null;

  // setNewLocation by calling geolocator and getting the current position and assigning latitude and longitude from there
  void setNewLocation(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }

  // 2ta private method akta method e rekhe call korlam
  // 2ta method identical sudhu api r model class ta different
  // 2ta method call korar madhome CurrentData r ForecastData niye asbe abong currenResponseModel ar forecastResponseModel e save korbe abong notifylistner call kore dibo kaj ses
  getWeatherDate() {
    _getCurrentData();
    _getForecastData();
  }

  void _getCurrentData() async {
    // String url link ta ke Uri te convert korlam
    final uri = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key");
    try {
      // json data get korlam uri theke
      final response = await get(uri);
      // json data decode kore map pelam
      final map = jsonDecode(response.body);
      if (response.statusCode == 200) {
        currentResponseModel = CurrentResponseModel.fromJson(map);
        // temp er data console asle bujbo data aseche
        print(currentResponseModel!.main!.temp!.round());
        // weather jehetu change hoi tai notifyListener kore dilam
        notifyListeners();
      } else {
        print(map["message"]);
      }
    } catch (error) {
      rethrow;
    }
  }

  void _getForecastData() async {
    // first string ke uri te convert kora
    final uri = Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key");
    try {
      // second browser e json data get kora
      final response = await get(uri);
      // jsonDecode korle amra json file ke map e convert korbo
      // response code jai hok na ken amara age map pabo
      final map = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // amra  map ta  ke object e convert korlam
        forecastResponseModel = ForecastResponseModel.fromJson(map);
        // list er length console e print hole mane data asche
        print(forecastResponseModel!.list!.length);
        notifyListeners();
      } else {
        print(map["message"]);
      }
    } catch (error) {
      rethrow;
    }
  }
}
