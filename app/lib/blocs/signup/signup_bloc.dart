// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../datasource/network/apis.dart';
//
// part 'signup_events.dart';
// part 'signup_state.dart';
//
// class SignupBloc extends Bloc<SignupEvents, SignupState> {
//   Api apiRepository;
//
//   SignupBloc(SignupState initialState, this.apiRepository)
//       : super(initialState);
//
//   @override
//   Stream<SignupState> mapEventToState(SignupEvents event) async* {
//     if (event is StartEvent) {
//       yield SignupInitState();
//     } else if (event is SignupButtonPressed) {
//       yield SignupLoadingState();
//       var data =
//           await apiRepository.Signup(event.name, event.email, event.password, event.job, event.phoneNumber );
//       if (data != null) {
//         if (data!.error.toString() == "Internal Server Error") {
//           print("dkioke");
//           yield SignupSuccessState();
//         } else if (data.error.toString() == "Username was exist") {
//           print("Username was exist");
//           yield SignupErrorState(message: data!.error.toString() ?? "");
//         }
//       } else {
//         print('data null ');
//       }
//     }
//   }
// }
