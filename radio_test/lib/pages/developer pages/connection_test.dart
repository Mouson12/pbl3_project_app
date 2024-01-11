import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTTP Connection Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: testPage(),
    );
  }
}

class testPage extends StatefulWidget {
  @override
  _testPageState createState() => _testPageState();
}

class _testPageState extends State<testPage> {
  String _responseText = '';

  Future<void> _establishConnection() async {
    final url =
        'https://perfect-hideously-akita.ngrok-free.app/'; // Replace with your API endpoint

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _responseText =
              'Connection established successfully!\nResponse: ${response.body}';
        });
      } else {
        setState(() {
          _responseText = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _responseText = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('HTTP Connection Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _establishConnection,
              child: Text('Establish Connection'),
            ),
            SizedBox(height: 20),
            Text(
              _responseText,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

/*void main() async {
  var client = InfluxDBClient(
    url: 'https://perfect-hideously-akita.ngrok-free.app',
    token:
        'DMCXaST4p0V8MsfAMhVGX3iH-Ebx3R8VjQv7tXOMrEVoSHE7Xuoxh98CACH6HiRZQoIewESZBqfPr2MNc7W_KA==',
    org: 'radio_measurements',
    bucket: 'radio_test_10.01',
    debug: true,
  );

  try {
    var healthCheck = await client.getHealthApi().getHealth();
    print(
        'Health check: ${healthCheck.name}/${healthCheck.version} - ${healthCheck.message}');
  } catch (e) {
    print('Error: $e');
  }

  client.close();
}*/
