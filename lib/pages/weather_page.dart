import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  _getData() {
    determinePosition().then((position) {
      provider.setNewLocation(position.latitude, position.longitude);
      provider.getWeatherDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Weather'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.my_location)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
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
          getFormattedDateTime(response!.dt!, 'MMM dd yyyy'),
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
                '${response.main!.temp!.round()}$degree$celsius',
                style: txtTempBig80,
              )
            ],
          ),
        ),
        Wrap(
          children: [
            Text(
              'feels like ${response.main!.feelsLike!.round()}$degree$celsius',
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
              'Sunrise ${getFormattedDateTime(response.sys!.sunrise!, 'hh:mm a')}%',
              style: txtNormal16,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Sunset ${getFormattedDateTime(response.sys!.sunset!, 'hh:mm a')}%',
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
    return Center();
  }
}
