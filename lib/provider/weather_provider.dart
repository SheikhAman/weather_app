import 'dart:convert';
import 'package:geocoding/geocoding.dart' as Geo;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/current_response_model.dart';
import 'package:weather_app/models/forecast_response_model.dart';
import 'package:weather_app/utils/constants.dart';

class WeatherProvider extends ChangeNotifier {
  CurrentResponseModel? currentResponseModel;
  ForecastResponseModel? forecastResponseModel;

  double latitude = 0, longitude = 0;

  String unit = 'metric';
  String unitSymbol = celsius;

// 2ta not null hole  return korbe true r data chole asle notifylistner call hobe abong data update pabo
  // hasDataLoaded er upor nirvor kore amra weatherpage e ki data show korbo ta nirvor korbe
  bool get hasDataLoaded =>
      currentResponseModel != null && forecastResponseModel != null;

  bool get isFahrenheit => unit == imperial;

  // setNewLocation by calling geolocator and getting the current position and assigning latitude and longitude from there
  void setNewLocation(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }

  // 2ta private method akta method e rekhe call korlam
  // 2ta method identical sudhu api r model class ta different
  // 2ta method call korar madhome CurrentData r ForecastData niye asbe abong currenResponseModel ar forecastResponseModel e save korbe abong notifylistner call kore dibo kaj ses
  getWeatherData() {
    _getCurrentData();
    _getForecastData();
  }

// ai method er kaj hoche variable er value change kora
  void setTempUnit(bool tag) {
    unit = tag ? imperial : metric;
    unitSymbol = tag ? fahrenheit : celsius;
    notifyListeners();
  }

  Future<bool> setPreferenceTemUnitValue(bool tag) async {
    // singalton object jodi agertheke create kora na thake tahole object create korbe nahoi ager file tai use korbe
    final pref = await SharedPreferences.getInstance();
    // key value pair akare save korte hoi
    return pref.setBool('unit', tag);
  }

  Future<bool> getPreferenceTempUnitValue() async {
    final pref = await SharedPreferences.getInstance();
    // get null return korte pare jodi null return kore tahole amra false return korbo
    // porthome user app open  korar somoy  set korar age get korar chesta korbe tokhon value null thakbe r tai false return korbe
    return pref.getBool('unit') ?? false;
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

// 2ta error aste pare user abcd type korse kono city ase nai
// arekta jinis hote pare user city dise kintu setar let long khute pai nai
  void convertAddressToLatLng(String result) async {
    try {
      final locationList = await Geo.locationFromAddress(result);
      if (locationList.isNotEmpty) {
        final location = locationList.first;
        setNewLocation(location.latitude, location.longitude);
        getWeatherData();
      } else {
        // list empty hole city not found
        print('City not found');
      }
    } catch (error) {
      print(error.toString());
    }
  }
}
