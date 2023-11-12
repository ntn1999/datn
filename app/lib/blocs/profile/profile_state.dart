part of 'profile_bloc.dart';

class ProFileState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProFileInitState extends ProFileState {}

class ProFileLoadingState extends ProFileState {}

class ProFileErrorState extends ProFileState {}

class ProFileLoadedState extends ProFileState {
  final UserResponse listProfile;

  ProFileLoadedState({required this.listProfile});

  @override
  List<Object> get props => [listProfile];
}
class ChangeProfileLoadingState extends ProFileState {}

class ChangeProFileSuccessState extends ProFileState {}

class ChangeProFileErrorState extends ProFileState {
  final String message;
  ChangeProFileErrorState({required this.message});
}

