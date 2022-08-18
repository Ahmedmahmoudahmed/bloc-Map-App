part of 'phone_auth_cubit.dart';

@immutable
abstract class PhoneAuthState {}

class PhoneAuthInitial extends PhoneAuthState {}

class Loading extends PhoneAuthState{}

class ErrorOccured extends PhoneAuthState{
  final String errorMsg;
  ErrorOccured({required this.errorMsg});
}

class PhoneNumberSubmitted extends PhoneAuthState{}

class PhoneOTPVerified extends PhoneAuthState{}