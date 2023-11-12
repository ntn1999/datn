import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../datasource/models/sensors_res.dart';
import '../../datasource/network/apis.dart';

part 'living_room_event.dart';

part 'living_room_state.dart';

enum Room { livingRoom, bedRoom, kitchen, bathroom }

extension RoomExt on Room {
  String get name {
    switch (this) {
      case Room.livingRoom:
        return 'Phòng khách';
      case Room.bedRoom:
        return 'Phòng ngủ';
      case Room.kitchen:
        return 'Nhà bếp';
      case Room.bathroom:
        return 'Nhà tắm';
    }
  }
}

class LivingRoomBloc extends Bloc<LivingRoomEvents, LivingRoomState> {
  LivingRoomBloc() : super(LivingRoomLoadingState());

  @override
  Stream<LivingRoomState> mapEventToState(LivingRoomEvents event) async* {
    var formatter = DateFormat('yyyy-MM-dd');
    // var now = DateTime.now();
    //
    //
    // String end= now.microsecondsSinceEpoch.toString();
    //  var beginTime = DateTime.now().subtract(Duration(hours:1));
    //  String begin = beginTime.microsecondsSinceEpoch.toString();

    final pref = await SharedPreferences.getInstance();
    String token = (pref.getString('token') ?? "");

    final apiRepository = Api();
    if (event is StartEvent) {
      yield LivingRoomInitState();
    } else if (event is LivingRoomEventStated) {
      yield LivingRoomLoadingState();
      var now = DateTime.now();
      String end = now.microsecondsSinceEpoch.toString();
      var beginTime = DateTime.now()
          .subtract(Duration(hours: int.tryParse(event.time) ?? 0));
      String begin = beginTime.microsecondsSinceEpoch.toString();
      var data = await apiRepository.getSensors(begin, end);
      //var data = await apiRepository.getSensors('1645542750000','1645546350000');
      if (data != null) {
        yield LivingRoomLoadedState(sensorsResponse: data);
      } else {
        yield LivingRoomErrorState();
      }
    }
  }
}
