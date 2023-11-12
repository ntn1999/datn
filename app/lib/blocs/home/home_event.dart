part of 'home_bloc.dart';

abstract class HomeEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class StartEvent extends HomeEvents {}

class HomeEventStated extends HomeEvents {
  // final String token;
  // ProfileEventStated({required this.token});
}
