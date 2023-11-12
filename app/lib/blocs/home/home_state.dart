part of 'home_bloc.dart';


class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

class HomeInitState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeErrorState extends HomeState {}

class HomeLoadedState extends HomeState {
  // final SensorsResponse sensorsResponse;
  //
  // HomeLoadedState({required this.sensorsResponse});
  //
  // @override
  // List<Object> get props => [sensorsResponse];
}
