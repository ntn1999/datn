part of 'change_password_bloc.dart';

abstract class ChangePasswordEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class StartEvent extends ChangePasswordEvents {}

class ChangePasswordButtonPressed extends ChangePasswordEvents {
  final String email;
  final String oldPassword;
  final String newPassword;

  ChangePasswordButtonPressed({
    required this.email,
    required this.oldPassword,
    required this.newPassword,
  });
}
