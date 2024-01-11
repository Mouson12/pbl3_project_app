// stats_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import '../features/core/querry_data.dart';
import 'package:meta/meta.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final fetchDataFuture = fetchData();

  StatsBloc() : super(StatsStateLoading()) {
    on<FetchDataEvent>(_handleFetchDataEvent);
  }

  void _handleFetchDataEvent(
      FetchDataEvent event, Emitter<StatsState> emit) async {
    try {
      final data = await fetchDataFuture;
      emit(StatsStateLoaded(data: data));
    } catch (e) {
      emit(StatsStateError(error: e.toString()));
    }
  }

  /*@override
  Stream<StatsState> mapEventToState(StatsEvent event) async* {
    // No need for explicit handling here as the event is handled by on<FetchDataEvent>
  }*/
}
