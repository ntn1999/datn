import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../datasource/network/apis.dart';

part 'change_password_events.dart';

part 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvents, ChangePasswordState> {
  Api apiRepository;

  ChangePasswordBloc(ChangePasswordState initialState, this.apiRepository)
      : super(initialState);

  @override
  Stream<ChangePasswordState> mapEventToState(
      ChangePasswordEvents event) async* {
    if (event is StartEvent) {
      yield ChangePasswordInitState();
    } else if (event is ChangePasswordButtonPressed) {
      yield ChangePasswordLoadingState();
      var data = await apiRepository.changePassword(
          event.email, event.oldPassword, event.newPassword);
      print(data);
      if (data?.message == 'change succsess') {
        yield ChangePasswordSuccessState();
      } else {
        yield ChangePasswordErrorState(message: data?.message ?? "Thay đổi thất bại");
      }
    }
  }
}
