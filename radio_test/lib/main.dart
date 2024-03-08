import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/map_page.dart';
import '../pages/stats_page.dart';
import '../pages/settings_page.dart';
import '../common/navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  List<Widget> pages = [
    const HomePage(title: 'Home'),
    MapPage(),
    const StatsPage(title: 'Stats'),
    const SettingsPage(title: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: buildNavBar(_selectedIndex, _onTabChange),
      ),
    );
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
