import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../datasource/models/user_res.dart';
import '../../datasource/network/apis.dart';

part 'profile_events.dart';

part 'profile_state.dart';

class ProFileBloc extends Bloc<ProFileEvents, ProFileState> {
  ProFileBloc() : super(ProFileLoadingState());

  @override
  Stream<ProFileState> mapEventToState(ProFileEvents event) async* {
    final pref = await SharedPreferences.getInstance();
    final apiRepository = Api();
    String token = (pref.getString('token') ?? "");
    String userId = (pref.getString('userId') ?? "");
    User user = User();
    if (event is StartEvent) {
      print("start_bloc");
      yield ProFileInitState();
    } else if (event is ProFileEventStated) {
      print("start_bloc2");
      yield ProFileLoadingState();
      var data = await apiRepository.getUser(token, userId);
      if (data?.user != null) {
        yield ProFileLoadedState(listProfile: data!);
      } else {
        yield ProFileErrorState();
      }
    } else if (event is ChangeProfilePressed) {
      // yield ChangeProfileLoadingState();
      var result = await apiRepository.changeProfile(
          name: event.name,
          phone: event.phone,
          address: event.address,
          id: userId);
      if (result?.user != null) {
        yield ChangeProFileSuccessState();
        var data = await apiRepository.getUser(token, userId);
        if (data?.user != null) {
          user = data?.user??User();
          yield ProFileLoadedState(listProfile: data!);
        } else {
          yield ProFileErrorState();
        }
      } else {
        yield ChangeProFileErrorState(message: 'Đã có lỗi xảy ra');
      }
    }
  }
}
