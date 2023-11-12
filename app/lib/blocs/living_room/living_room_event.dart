part of 'living_room_bloc.dart';


abstract class LivingRoomEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class StartEvent extends LivingRoomEvents {}

class LivingRoomEventStated extends LivingRoomEvents {
  final String time;
  LivingRoomEventStated({required this.time});
}
