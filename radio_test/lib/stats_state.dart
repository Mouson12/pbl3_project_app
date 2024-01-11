part of 'stats_bloc.dart';

@immutable
abstract class StatsState {}

class StatsStateLoading extends StatsState {}

class StatsStateLoaded extends StatsState {
  final List<List<DataPoint>> data;

  StatsStateLoaded({required this.data});
}

class StatsStateError extends StatsState {
  final String error;

  StatsStateError({required this.error});
}
