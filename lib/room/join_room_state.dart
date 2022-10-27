import '../cubit/base_states.dart';

class RoomInitial extends CubitBaseState {
  factory RoomInitial.init() {
    return RoomInitial();
  }
  RoomInitial();
}

class RoomError extends CubitBaseState {
  String error;
  RoomError({required this.error});
}

class RoomLoaded extends CubitBaseState {
  String name, token, identity;
  RoomLoaded({required this.name, required this.token, required this.identity});
}

class RoomLoading extends CubitBaseState {
  RoomLoading();
}
