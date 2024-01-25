import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../features/core/querry_data.dart';
import '../stats_bloc.dart';
import 'package:async/async.dart';
import 'package:numberpicker/numberpicker.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late StatsBloc _statsBloc;
  late Future<List<List<DataPoint>>> _dataFuture;
  String timeRange = "-5m";

  @override
  void initState() {
    super.initState();
    _statsBloc = StatsBloc();
    _dataFuture = fetchData(timeRange);
  }

  Future<void> _showCustomTimePicker() async {
    int selectedValue = 1;
    String selectedUnit = 'm';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(child: Text('Select Time Range')),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NumberPicker(
                        value: selectedValue,
                        minValue: 1,
                        maxValue: 60, // Adjust as needed
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;
                          });
                        },
                      ),
                      DropdownButton<String>(
                        value: selectedUnit,
                        borderRadius: BorderRadius.circular(16),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedUnit = newValue!;
                          });
                        },
                        items: [
                          {'display': 'Minutes', 'abbreviation': 'm'},
                          {'display': 'Hours', 'abbreviation': 'h'},
                          {'display': 'Days', 'abbreviation': 'd'},
                          {'display': 'Weeks', 'abbreviation': 'w'},
                          //{'display': 'Months', 'abbreviation': 'M'},
                          //{'display': 'Years', 'abbreviation': 'Y'},
                        ].map<DropdownMenuItem<String>>((dynamic value) {
                          return DropdownMenuItem<String>(
                            value: value['abbreviation'],
                            child: Center(child: Text(value['display'])),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle the selected time range (selectedValue and selectedUnit)
                      print(
                          'Selected Time Range: $selectedValue $selectedUnit');
                      _updateData('-$selectedValue$selectedUnit');
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _updateData(String newTimeRange) {
    setState(() {
      timeRange = newTimeRange;
      _dataFuture = fetchData(timeRange);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 2,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _updateData('-1m');
                        },
                        child: Text(
                          'Min',
                          textScaler: TextScaler.linear(0.8),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _updateData('-5m');
                        },
                        child: Text(
                          '5 min',
                          textScaler: TextScaler.linear(0.8),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _updateData('-15m');
                        },
                        child: Text(
                          '15 min',
                          textScaler: TextScaler.linear(0.8),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showCustomTimePicker();
                        },
                        child: Text(
                          'Custom',
                          textScaler: TextScaler.linear(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<List<List<DataPoint>>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    var rssiData = snapshot.data![0];
                    var audioLevelData = snapshot.data![1];

                    if (rssiData.isEmpty && audioLevelData.isEmpty) {
                      // Data is empty, display a message in the center of the screen
                      return Center(
                        child: Text('No Data. Please refresh.'),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'RSSI Level',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        //SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 20,
                            height: MediaQuery.of(context).size.height *
                                0.25, // Set height as needed
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                ),
                                titlesData: FlTitlesData(
                                  show: false,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: false,
                                    ),
                                  ),
                                  //bottomTitles: AxisTitles(),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: rssiData.map((point) {
                                      return FlSpot(
                                        point.time.millisecondsSinceEpoch
                                            .toDouble(),
                                        point.value,
                                      );
                                    }).toList(),
                                    isCurved: true,
                                    color: Colors.blue,
                                    dotData: FlDotData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'RF Signal Level',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ), // Adjust as needed
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 20,
                            height: MediaQuery.of(context).size.height *
                                0.25, // Set height as needed
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                ),
                                titlesData: FlTitlesData(
                                    show: false,
                                    topTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                      showTitles: false,
                                    )
                                        //rightTitles: SideTitles(showTitles: false),
                                        /*leftTitles: SideTitles(
        showTitles: true,
        getTextStyles:  , // Adjust font size as needed
      ),
                                    topTitles: SideTitles(showTitles: false),
                                    bottomTitles: SideTitles(
                                        showTitles: false,
                                        margin: 8, // Adjust margin as needed
                                        //reservedSize: 22, // Adjust reservedSize as needed
                                        // interval:1, // Adjust interval as needed
                                        // Adjust text style as needed
                                        getTitles: (value) {
                                          // You can customize how the titles appear on the X-axis
                                          // For example, if values represent time in minutes, you can convert them to a specific format
                                          // Here, I'm assuming the values are in minutes
                                          return '${value.toInt()} min';
                                        })*/
                                        )),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: audioLevelData.map((point) {
                                      return FlSpot(
                                        point.time.millisecondsSinceEpoch
                                            .toDouble(),
                                        point.value,
                                      );
                                    }).toList(),
                                    isCurved: true,
                                    color: Colors.red,
                                    dotData: FlDotData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Text('Unknown state');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _statsBloc.close();
    super.dispose();
  }
}
