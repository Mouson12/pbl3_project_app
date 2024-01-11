import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../features/core/querry_data.dart';
import '../stats_bloc.dart';
import 'package:async/async.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late StatsBloc _statsBloc;
  late Future<List<List<DataPoint>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _statsBloc = StatsBloc();
    _dataFuture = fetchData();
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
              SizedBox(height: 16),
              FutureBuilder<List<List<DataPoint>>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                    //return Text('Loading...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    var rssiData = snapshot.data![0];
                    var audioLevelData = snapshot.data![1];

                    return Container(
                      width:
                          MediaQuery.of(context).size.width - 20, // 10 per side
                      height: MediaQuery.of(context).size.height *
                          0.3, // 30 percent of screen height // Set height as needed
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            //horizontalInterval: 1,
                            //verticalInterval: 1,
                          ),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: rssiData.map((point) {
                                return FlSpot(
                                  point.time.millisecondsSinceEpoch.toDouble(),
                                  point.value,
                                );
                              }).toList(),
                              isCurved: true,
                              color: Colors.blue,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: audioLevelData.map((point) {
                                return FlSpot(
                                  point.time.millisecondsSinceEpoch.toDouble(),
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
