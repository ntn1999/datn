import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../datasource/models/sensors_res.dart';
import '../../datasource/network/apis.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvents, HomeState> {
  HomeBloc() : super(HomeLoadingState());

  @override
  Stream<HomeState> mapEventToState(HomeEvents event) async* {
    var formatter = DateFormat('yyyy-MM-dd');
    // var now = DateTime.now();
    // String currentDate = formatter.format(now);
    //
    // var yesterday = DateTime.now().subtract(Duration(days:1));
    // String yesterdayDate = formatter.format(yesterday);

    final apiRepository = Api();
    if (event is StartEvent) {
      yield HomeInitState();
    } else if (event is HomeEventStated) {
      yield HomeLoadingState();
      yield HomeLoadedState();
      // var data = await apiRepository.getSensors(currentDate, yesterdayDate);
      // if (data != null) {
      //   yield HomeLoadedState(sensorsResponse: data);
      // } else {
      //   yield HomeErrorState();
      // }
    }
  }
}
