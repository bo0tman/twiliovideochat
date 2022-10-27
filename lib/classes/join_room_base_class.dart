import '../cubit/base_states.dart';

class RoomInitial extends CubitBaseState {
  // factory RoomInitial._() {
  //   return RoomInitial();
  // }
  RoomInitial();
}

class RoomError extends CubitBaseState {
  String error;

  // factory RoomError._() {
  //   return RoomError(error: 'Something went wrong');
  // }
  RoomError({required this.error});
}

class RoomLoaded extends CubitBaseState {
  String name, token, identity;
  RoomLoaded({required this.name, required this.token, required this.identity});
}

class RoomLoading extends CubitBaseState {
  // factory RoomLoading._() {
  //   return RoomLoading();
  // }
  RoomLoading();
}
