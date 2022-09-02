import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/pages/settings_page.dart';
import 'package:weather_app/provider/weather_provider.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/utils/helper_function.dart';
import 'package:weather_app/utils/location_utils.dart';
import 'package:weather_app/utils/text_styles.dart';

class WeatherPage extends StatefulWidget {
  static const String routeName = '/';
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late WeatherProvider provider;
  bool isFirst = true;

  Timer? timer;

  @override
  void didChangeDependencies() {
    if (isFirst) {
      // provider er method initialization korlam
      provider = Provider.of<WeatherProvider>(context);
      _getData();
      // false kore dilam
      isFirst = false;
    }
    super.didChangeDependencies();
  }

  _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      print('timer started');
      final isOn = await Geolocator.isLocationServiceEnabled();
      if (isOn) {
        _stopTimer();
        _getData();
      }
    });
  }

  _stopTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  _getData() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      showMsgWithAction(
          context: context,
          msg: 'Please turn on location',
          callback: () async {
            _startTimer();
            final status = await Geolocator.openLocationSettings();
            print(status);
          });
      return;
    }
    try {
      final position = await determinePosition();
      provider.setNewLocation(position.latitude, position.longitude);
      provider.setTempUnit(await provider.getPreferenceTempUnitValue());
      provider.getWeatherData();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1b0050),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Weather'),
        actions: [
          IconButton(
              onPressed: () {
                _getData();
              },
              icon: const Icon(Icons.my_location)),
          IconButton(
              onPressed: () async {
                // search page theke ber howar por result back dibe aita empty o hote pare datePicker er moto
                final result = await showSearch(
                    context: context, delegate: _CitySearchDelegate());
                if (result != null && result.isNotEmpty) {
                  provider.convertAddressToLatLng(result);
                  print(result);
                }
              },
              icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, SettingsPage.routeName),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: provider.hasDataLoaded
            ? ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _currentWeatherSection(),
                  _forecastWeatherSection(),
                ],
              )
            : const Text(
                'Please wait...',
                style: txtNormal16,
              ),
      ),
    );
  }

  Widget _currentWeatherSection() {
    // bar bar object na likhe object ta variable e niye rakhlam
    final response = provider.currentResponseModel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          // getFormattedDateTime(response!.dt!, 'MMM dd yyyy'),
          getFormattedDate(response!.dt!, "dd/MM/yyyy"),
          style: txtDateHeader18,
        ),
        Text(
          '${response.name},${response.sys!.country}',
          style: txtAddress24,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // IconPrefix r IconSuffix cocade kore add korbo
              Image.network(
                '$iconPrefix${response.weather![0].icon}$iconSuffix',
                fit: BoxFit.cover,
              ),
              Text(
                '${response.main!.temp!.round()}$degree${provider.unitSymbol}',
                style: txtTempBig80,
              )
            ],
          ),
        ),
        Wrap(
          children: [
            Text(
              'feels like ${response.main!.feelsLike!.round()}$degree${provider.unitSymbol}',
              style: txtNormal16,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              '${response.weather![0].main},${response.weather![0].description}',
              style: txtNormal16,
            )
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          children: [
            Text(
              'Humidity ${response.main!.humidity}%',
              style: txtNormal16White54,
            ),
            const SizedBox(
              width: 10,
            ),
            Text('Pressure ${response.main!.pressure}hPa',
                style: txtNormal16White54),
            const SizedBox(
              width: 10,
            ),
            Text('Visibility ${response.visibility}meter',
                style: txtNormal16White54),
            const SizedBox(
              width: 10,
            ),
            Text('Wind ${response.wind!.speed}m/s', style: txtNormal16White54),
            const SizedBox(
              width: 10,
            ),
            Text('Degree ${response.wind!.deg}$degree',
                style: txtNormal16White54)
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          children: [
            Text(
              'Sunrise ${getFormattedTime(response.sys!.sunrise!, 'hh:mm:ss')}',
              style: txtNormal16,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Sunset ${getFormattedTime(response.sys!.sunset!, 'hh:mm:ss')}',
              style: txtNormal16,
            ),
            Text('Visibility ${response.visibility}meter',
                style: txtNormal16White54),
            const SizedBox(
              width: 10,
            ),
          ],
        )
      ],
    );
  }

  Widget _forecastWeatherSection() {
    final response = provider.forecastResponseModel;
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Text(
          "Forecast Weather",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 1,
              wordSpacing: 1),
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: response!.list!.length,
            itemBuilder: (context, index) {
              final model = response.list![index];

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      getFormattedDate(
                        model.dt!,
                        "pattern",
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    Text(
                      getFormattedTime(model.dt!, "pattern"),
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    Image.network(
                      "$iconPrefix${model.weather![0].icon}$iconSuffix",
                      color: Colors.amber,
                      height: 80,
                    ),
                    Text(
                        "${model.main!.temp!.round()}$degree${provider.unitSymbol}",
                        style: TextStyle(color: Colors.white)),
                    Text("${model.weather![0].description}",
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                    Text(
                        "${model.main!.tempMin!.round()}$degree${provider.unitSymbol} / ${model.main!.tempMax!.round()}$degree${provider.unitSymbol}",
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
                margin: EdgeInsets.all(5),
                height: 220,
                width: 135,
                decoration: BoxDecoration(
                    color: Color(0xff3f2786).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15)),
              );
            },
          ),
        )
      ],
    );
  }
}

// porthome city list er filter list banate hobe karon user jeta match korabe city setar shate match koriye konta konta show korabo
// query field ta SearchDelegate parent class theke asche
// query hoche getter method ja apnake akta string return kore user jeta type korbe seta
class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            // cross click korle query ba empty kore dilam
            query = '';
          },
          icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        onPressed: () {
          // searchDelegate er method hoche close, click korle close hoye jabe
          close(context, '');
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    // user jeta type  korche seta list e nai tarpor search icon e click korse tai result ta kichu khon dekhabe
    return ListTile(
      leading: Icon(Icons.search),
      title: Text(query),
      onTap: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // je city gulo  ache seta jodi  query er shate match kore tahole seguloke niye list e convert kore filterdList e rakhe dibo
    final filteredList = query.isEmpty
        ? cities
        : cities
            .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) => ListTile(
              title: Text(filteredList[index]),
              onTap: () {
                // user jodi filteredList theke tar city pai tahole query er vitore city ta rekhe dichi
                query = filteredList[index];
                // ar tar por search dialogue ta close kore dichi
                close(context, query);
              },
            ));
  }
}
