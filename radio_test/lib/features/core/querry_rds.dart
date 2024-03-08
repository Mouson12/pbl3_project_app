import 'dart:io';
import 'package:influxdb_client/api.dart';

class DataPoint {
  final DateTime time;
  final String value;

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
    |> filter(fn: (r) => r["_field"] == "RDS_PI" or r["_field"] == "RDS_PS")
    |> aggregateWindow(every: 10s, fn: mean, createEmpty: false)
    |> yield(name: "mean")  
  ''';

  var recordStream = await queryService.query(fluxQuery);

  var rdsPiRecords = List<DataPoint>.empty(growable: true);
  var rdsPsRecords = List<DataPoint>.empty(growable: true);

  try {
    await for (var record in recordStream) {
      var field = record['_field'];
      var time = DateTime.parse(record['_time']);
      var value = record['_value'].toString(); // Assuming value is a string

      if (field == 'RDS_PI') {
        rdsPiRecords.add(DataPoint(time, value));
      } else if (field == 'RDS_PS') {
        rdsPsRecords.add(DataPoint(time, value));
      }
    }

    print('RDS_PI Records:');
    for (var rdsPiRecord in rdsPiRecords) {
      print('Time: ${rdsPiRecord.time}, Value: ${rdsPiRecord.value}');
    }

    print('\nRDS_PS Records:');
    for (var rdsPsRecord in rdsPsRecords) {
      print('Time: ${rdsPsRecord.time}, Value: ${rdsPsRecord.value}');
    }
  } catch (e) {
    print('Error fetching data: $e');
  } finally {
    client.close();
  }

  return [rdsPiRecords, rdsPsRecords];
}
