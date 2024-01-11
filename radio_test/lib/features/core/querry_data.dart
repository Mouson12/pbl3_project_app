import 'dart:io';
import 'package:influxdb_client/api.dart';

class DataPoint {
  final DateTime time;
  final double value;

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

Future<List<List<DataPoint>>> fetchData() async {
  HttpOverrides.global = DevHttpOverrides();

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
    |> range(start: -15m, stop: now()) 
    |> filter(fn: (r) => r["_measurement"] == "mqtt_consumer") 
    |> filter(fn: (r) => r["_field"] == "RSSI" or r["_field"] == "audio_level")
    |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
    |> yield(name: "mean")  
  ''';

  // query to stream and iterate all records
  var recordStream = await queryService.query(fluxQuery);

  var rssiRecords = List<DataPoint>.empty(growable: true);
  var audioLevelRecords = List<DataPoint>.empty(growable: true);

  try {
    await for (var record in recordStream) {
      var field = record['_field'];
      var time = DateTime.parse(record['_time']);
      var value = record['_value'].toDouble(); // Assuming value is numeric

      if (field == 'RSSI') {
        rssiRecords.add(DataPoint(time, value));
      } else if (field == 'audio_level') {
        audioLevelRecords.add(DataPoint(time, value));
      }
    }
    /*print('RSSI Records:');
    for (var rssiRecord in rssiRecords) {
      print('Time: ${rssiRecord.time}, Value: ${rssiRecord.value}');
    }

    print('\nAudio Level Records:');
    for (var audioLevelRecord in audioLevelRecords) {
      print('Time: ${audioLevelRecord.time}, Value: ${audioLevelRecord.value}');
    }*/
  } catch (e) {
    print('Error fetching data: $e');
  } finally {
    client.close();
  }

  return [rssiRecords, audioLevelRecords];
}
