import 'dart:async';
import 'package:bloc/bloc.dart';
import '../features/core/querry_data.dart';
import 'package:meta/meta.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc() : super(StatsStateLoading()) {
    on<FetchDataEvent>(_mapFetchDataToState);
  }

  Stream<StatsState> _mapFetchDataToState(
      FetchDataEvent event, Emitter<StatsState> emit) async* {
    try {
      final String timeRange = event.timeRange;
      final data = await fetchData(timeRange);
      yield StatsStateLoaded(data: data);
    } catch (e) {
      yield StatsStateError(error: e.toString());
    }
  }
}
