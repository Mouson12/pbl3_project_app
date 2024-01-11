import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import '../pages/developer pages/connection_test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SettingsPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Account'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.person),
                title: Text('Personal Data'),
                // add adding device
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.logout),
                title: Text('Sign out'),
                // add current device list
              ),
            ],
          ),
          SettingsSection(
            title: Text('Common'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('Language'),
                value: Text('English'),
                // add language options
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                // make handling for dynamic system theme change
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.format_paint),
                title: Text('Change theme'),
                // make handling for dynamic system theme change
              ),
            ],
          ),
          SettingsSection(
            title: Text('Device'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.device_hub),
                title: Text('Add device'),
                // add adding device
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.list),
                title: Text('Device list'),
                // add current device list
              ),
            ],
          ),
          SettingsSection(
            title: Text('Developer options'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.connecting_airports_outlined),
                title: Text('Test connection'),
                onPressed: (BuildContext? context) {
                  Navigator.push(
                    context!,
                    MaterialPageRoute(builder: (context) => testPage()),
                  );
                },
                // add adding device
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.bug_report),
                title: Text('Report bug'),
                // add current device list
              ),
            ],
          ),
          SettingsSection(
            title: Text('About'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.info),
                title: Text('About Application'),
                // add adding device
              ),
            ],
          ),
        ],
      ),
    );
  }
}
