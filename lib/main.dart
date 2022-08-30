import 'package:flutter/material.dart';
import 'package:weather_app/pages/settings_page.dart';
import 'package:weather_app/pages/weather_page.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider/weather_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'MerriWeatherSans',
        primarySwatch: Colors.blue,
      ),
      initialRoute: WeatherPage.routeName,
      routes: {
        WeatherPage.routeName: (_) => WeatherPage(),
        SettingsPage.routeName: (_) => SettingsPage()
      },
    );
  }
}
