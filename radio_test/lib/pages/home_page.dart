import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../features/core/querry_status_code.dart';
import '../common/status_code_widget.dart';
import 'package:google_fonts/google_fonts.dart';

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
        fontFamily: 'Montserrat',
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

  void _setupMqtt() async {
    client = MqttServerClient('0.tcp.eu.ngrok.io', 'flutter_client');
    client?.port = 18097;

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

    await _connect(); // Wait for the connection to be established

    // Subscribe to the 'freq' topic
    //client?.subscribe('freq', MqttQos.atMostOnce);

    // Handle incoming messages on the 'freq' topic
    client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage receivedMessage =
          c[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
          receivedMessage.payload.message);

      // Update the displayed frequency text
      setState(() {
        _displayedFrequency = payload;
      });
    });
  }

  Future<void> _connect() async {
    try {
      await client?.connect();
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _onConnected() {
    print('Connected to the broker');
  }

  void _onDisconnected() {
    print('Disconnected from the broker');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.asset(
          "assets/logo.png",
          fit: BoxFit.contain,
          height: 66,
        ),
        toolbarHeight: 88,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Choose Radio Frequency [MHz]',
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
                width: screenWidth - 40,
                height: screenHeight * 0.2,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '$_displayedFrequency',
                    style: GoogleFonts.rubik(
                      fontSize: 80,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            RefreshableStatusCodeWidget(),
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
                      setState(() {
                        _displayedFrequency = _frequencyController.text;
                      });
                      Navigator.pop(context);
                      _publishFrequency();
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
