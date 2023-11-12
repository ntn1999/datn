part of 'device_bloc.dart';

abstract class DeviceEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class StartEvent extends DeviceEvents {}

class DeviceEventStated extends DeviceEvents {}


class DeviceReportPressed extends DeviceEvents {
  final String id;
  final String note;
  DeviceReportPressed( {
    required this.id,
    required this.note,
  });
}