import 'dart:io';
import 'package:influxdb_client/api.dart';

class DataPoint {
  final DateTime time;
  final int value;

  DataPoint(this.time, this.value);
}

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<List<List<DataPoint>>> fetchData(String timeRange) async {
  HttpOverrides.global = DevHttpOverrides();

  try {
    var client = InfluxDBClient(
      url: 'https://perfect-hideously-akita.ngrok-free.app',
      token:
          'DMCXaST4p0V8MsfAMhVGX3iH-Ebx3R8VjQv7tXOMrEVoSHE7Xuoxh98CACH6HiRZQoIewESZBqfPr2MNc7W_KA==',
      org: 'radio_measurements',
      bucket: 'radio_test_10.01',
      debug: true,
    );

    // Reading the data
    var queryService = client.getQueryService();

    var fluxQuery = '''
      from(bucket: "radio_test_10.01")
      |> range(start: $timeRange, stop: now()) 
      |> filter(fn: (r) => r["_measurement"] == "mqtt_consumer") 
      |> filter(fn: (r) => r["_field"] == "status_code")
      |> aggregateWindow(every: 10s, fn: mean, createEmpty: false)
      |> yield(name: "mean")  
    ''';

    // query to stream and iterate all records
    var recordStream = await queryService.query(fluxQuery);

    var statusCodeRecords = List<DataPoint>.empty(growable: true);

    await for (var record in recordStream) {
      var field = record['_field'];
      var time = DateTime.parse(record['_time']);
      var value =
          double.parse((record['_value'].toDouble() ?? 0.0).toStringAsFixed(1));
      var intValue = value.round();

      if (field == 'status_code') {
        statusCodeRecords.add(DataPoint(time, intValue));
      }
    }

    print('Status Code Records:');
    for (var statuscodeRecord in statusCodeRecords) {
      print('Time: ${statuscodeRecord.time}, Value: ${statuscodeRecord.value}');
    }

    return [statusCodeRecords];
  } catch (e) {
    print('Error fetching data: $e');
    // Handle the specific exception if needed
    if (e is InfluxDBException && e.statusCode == 404) {
      print('Tunnel or resource not found.');
      // Handle accordingly, e.g., show a user-friendly message or log it.
    }
    return []; // or throw the exception again if you want to propagate it
  }
}
