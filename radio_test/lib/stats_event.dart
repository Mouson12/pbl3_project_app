part of 'stats_bloc.dart';

@immutable
abstract class StatsEvent {}

class FetchDataEvent extends StatsEvent {
  final String timeRange;

  FetchDataEvent({required this.timeRange});
}
