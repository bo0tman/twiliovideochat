import '../cubit/base_states.dart';

class ConferenceInitial extends CubitBaseState {
  factory ConferenceInitial.init() {
    return ConferenceInitial();
  }
  ConferenceInitial();
}

class ConferenceError extends CubitBaseState {
  String error;
  ConferenceError({required this.error});
}

class ConferenceLoaded extends CubitBaseState {
  String name, token, identity;
  ConferenceLoaded(
      {required this.name, required this.token, required this.identity});
}

class ConferenceLoading extends CubitBaseState {
  ConferenceLoading();
}
