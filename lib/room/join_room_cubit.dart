import 'package:twiliovideochat/cubit/base_states.dart';
import 'package:twiliovideochat/shared/twilio_service.dart';
import '../cubit/base_cubit.dart';
import 'join_room_state.dart';

class JoinRoomCubit extends TwilioBaseCubit<CubitBaseState> {
  // JoinRoomCubit() : super(()) {

  // }

  JoinRoomCubit() : super(RoomInitial.init());

  String? token;
  // String? identity;

  submit(name, identity) async {
    emit(RoomLoading());

    try {
      final twilioRoomTokenResponse =
          await TwilioFunctionsService.instance.createToken(identity!);
      print(twilioRoomTokenResponse);
      token = twilioRoomTokenResponse['accessToken'];
      // print(token);
      // identity = twilioRoomTokenResponse['user'];
      // print(identity);
      if (token != null && identity != null) {
        emit(RoomLoaded(name: name ?? '', token: token!, identity: identity!));
      } else {
        emit(RoomError(error: 'Access token is empty!'));
      }
    } catch (e) {
      emit(RoomError(
          error: 'Something wrong happened when getting the access token'));
    } finally {}
  }
}
