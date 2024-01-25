import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Publisher App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'MQTT Publisher'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  TextEditingController _frequencyController = TextEditingController();
  String _displayedFrequency = '100.0'; // Default frequency

  MqttServerClient? client;

  @override
  void initState() {
    super.initState();
    _setupMqtt();
  }

  void _setupMqtt() {
    client = MqttServerClient('2.tcp.eu.ngrok.io', 'flutter_client');
    client?.port = 16784;

    client?.logging(on: false);
    client?.keepAlivePeriod = 30;

    client?.onDisconnected = _onDisconnected;
    client?.onConnected = _onConnected;

    final MqttConnectMessage connectMessage = MqttConnectMessage()
        .authenticateAs('', '')
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client?.connectionMessage = connectMessage;

    _connect();
  }

  void _onConnected() {
    print('Connected to the broker');
  }

  void _onDisconnected() {
    print('Disconnected from the broker');
  }

  void _connect() async {
    try {
      await client?.connect();
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Choose Radio Frequency',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                _showNumericKeyboard(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$_displayedFrequency MHz',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNumericKeyboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter Frequency',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _frequencyController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Frequency (MHz)'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _publishFrequency();
                      setState(() {
                        _displayedFrequency = _frequencyController.text;
                      });
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _publishFrequency() {
    final String topic = 'freq';
    final String message = '$_displayedFrequency';

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    client?.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }
}
