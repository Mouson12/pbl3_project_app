import 'dart:async';
import 'package:flutter/material.dart';
import '../features/core/querry_status_code.dart'; // Import your data fetching logic

class RefreshableStatusCodeWidget extends StatefulWidget {
  @override
  _RefreshableStatusCodeWidgetState createState() =>
      _RefreshableStatusCodeWidgetState();
}

class _RefreshableStatusCodeWidgetState
    extends State<RefreshableStatusCodeWidget> {
  DataPoint? lastStatusCodeRecord;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    lastStatusCodeRecord = null; // Initialize with null

    // Fetch initial data and start a timer for periodic refresh
    fetchDataAndUpdate();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
      fetchDataAndUpdate();
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void fetchDataAndUpdate() async {
    // Fetch data and update the state
    var data = await fetchData("-1m");

    /*if (data[0].isNotEmpty) {
      setState(() {
        lastStatusCodeRecord = data[0].last;
      });
    }*/
  }

  String getLastStatusCodeBinary() {
    // Convert the last status code to binary
    return lastStatusCodeRecord != null
        ? lastStatusCodeRecord!.value.toRadixString(2).padLeft(16, '0')
        : '';
  }

  String getRSSI() {
    String binaryValue = getLastStatusCodeBinary();
    return binaryValue.isNotEmpty ? binaryValue.substring(14, 16) : '';
  }

  String getAudioLevel() {
    String binaryValue = getLastStatusCodeBinary();
    return binaryValue.isNotEmpty ? binaryValue.substring(12, 14) : '';
  }

  String getRDS_PI() {
    String binaryValue = getLastStatusCodeBinary();
    return binaryValue.isNotEmpty ? binaryValue.substring(10, 12) : '';
  }

  String getRDS_PS() {
    String binaryValue = getLastStatusCodeBinary();
    return binaryValue.isNotEmpty ? binaryValue.substring(8, 10) : '';
  }

  String getRDS_RT() {
    String binaryValue = getLastStatusCodeBinary();
    return binaryValue.isNotEmpty ? binaryValue.substring(4, 8) : '';
  }

  String interpretRSSI(String rssi) {
    switch (rssi) {
      case '00':
        return 'Strong Signal';
      case '01':
        return 'Poor Signal Quality';
      case '10':
        return 'No Signal';
      default:
        return 'Nothing';
    }
  }

  String interpretAudio(String audio) {
    switch (audio) {
      case '00':
        return 'Strong Signal';
      case '01':
        return 'Poor Signal Quality';
      case '10':
        return 'Silence';
      default:
        return 'Incorrect Data';
    }
  }

  String interpretRDSPI(String rds_pi) {
    switch (rds_pi) {
      case '00':
        return 'Correct PI';
      case '01':
        return 'Empty PI';
      case '10':
        return 'Bad Data Format';
      default:
        return 'No RDS';
    }
  }

  String interpretRDSPS(String rds_ps) {
    switch (rds_ps) {
      case '00':
        return 'Correct PS';
      case '01':
        return 'Empty PS';
      case '10':
        return 'Bad Data Format';
      default:
        return 'No RDS';
    }
  }

  String interpretRDSRT(String rds_rt) {
    switch (rds_rt) {
      case '0000':
        return 'Correct RT';
      case '0001':
        return 'Empty RT';
      case '1111':
        return 'No RDS';
      default:
        return 'Incorrect Data';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth - 40, // Adjust as needed
      height: screenHeight * 0.4,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.pink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Status Code Records',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10),
          if (lastStatusCodeRecord == null)
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 160,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40),
                        Text(
                          'RSSI',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Audio',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'RDS PI',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'RDS PS',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'RDS RT',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40),
                        Text(
                          '${interpretRSSI(getRSSI())}',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${interpretAudio(getAudioLevel())}',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${interpretRDSPI(getRDS_PI())}',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${interpretRDSPS(getRDS_PS())}',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${interpretRDSRT(getRDS_RT())}',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
