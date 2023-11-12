part of 'living_room_bloc.dart';



class LivingRoomState extends Equatable {
  @override
  List<Object> get props => [];
}

class LivingRoomInitState extends LivingRoomState {}

class LivingRoomLoadingState extends LivingRoomState {}

class LivingRoomErrorState extends LivingRoomState {}

class LivingRoomLoadedState extends LivingRoomState {
  final SensorsResponse sensorsResponse;


  LivingRoomLoadedState({required this.sensorsResponse} );

  @override
  List<Object> get props => [sensorsResponse];
}
