import 'dart:async';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';
import 'package:twiliovideochat/conference/participant_widget.dart';
import 'package:twiliovideochat/cubit/base_cubit.dart';
import 'package:twiliovideochat/cubit/base_states.dart';
import 'package:uuid/uuid.dart';
import 'conference_state.dart';

class ConferenceCubit extends TwilioBaseCubit<CubitBaseState> {
  String name, token, identity;
  Room? _room;
  // final Completer<Room> _completer = Completer<Room>();
  CameraCapturer? _cameraCapturer;
  String? trackId;
  var _streamSubscriptions;
  var _participants;
  ConferenceCubit({
    required this.name,
    required this.token,
    required this.identity,
  }) : super(ConferenceInitial()) {
    connect();
  }

  connect() async {
    print('[ APPDEBUG ] ConferenceRoom.connect()');
    try {
      await TwilioProgrammableVideo.requestPermissionForCameraAndMicrophone();
      // await TwilioProgrammableVideo.setSpeakerphoneOn(true);
      final sources = await CameraSource.getSources();
      _cameraCapturer = CameraCapturer(
        sources.firstWhere((source) => source.isFrontFacing),
      );
      var localVideoTrack = LocalVideoTrack(true, _cameraCapturer!);
      var widget = localVideoTrack.widget();

      print(_cameraCapturer);
      trackId = const Uuid().v4();
      print(trackId);

      var connectOptions = ConnectOptions(
        token,
        roomName: name,
        preferredAudioCodecs: [OpusCodec()],
        audioTracks: [LocalAudioTrack(true, 'audio_track-$trackId')],
        // audioTracks: [LocalAudioTrack(true, 'audio_track-$trackId')],
        dataTracks: [
          LocalDataTrack(
            DataTrackOptions(name: 'data_track-$trackId'),
          )
        ],
        videoTracks: [LocalVideoTrack(true, _cameraCapturer!)],
        enableNetworkQuality: true,
        networkQualityConfiguration: NetworkQualityConfiguration(
          remote: NetworkQualityVerbosity.NETWORK_QUALITY_VERBOSITY_MINIMAL,
        ),
        enableDominantSpeaker: true,
      );

      _room = await TwilioProgrammableVideo.connect(connectOptions);

      _streamSubscriptions.add(_room!.onConnected.listen(_onConnected));
      _streamSubscriptions.add(_room!.onDisconnected.listen(_onDisconnected));
      _streamSubscriptions.add(_room!.onReconnecting.listen(_onReconnecting));
      _streamSubscriptions
          .add(_room!.onConnectFailure.listen(_onConnectFailure));

      // _room!.onConnected.listen(_onConnected);
      // _room!.onConnectFailure.listen(_onConnectFailure);
      // _room!.onParticipantConnected.listen(_onParticipantConnected);
      // _room!.onParticipantConnected.listen(_onParticipantDisconnected);
      // return _completer.future;
    } catch (err) {
      print('[ APPDEBUG ] $err');
      rethrow;
    }
  }

  // Future<void> _onConnected(Room room) async {
  //   print('Connected to ${room.name}');

  // }

//   Future<void>  _onConnectFailure(RoomConnectFailureEvent event) async{
//     print('Failed connecting, exception: ${event.exception!.message}');
// };

// Future<void>  _onDisconnected(RoomDisconnectedEvent event) async{
//   print('Disconnected from ${event.room.name}');
// }
// Future<void>  _onParticipantConnected(RoomParticipantConnectedEvent event) async{
//   print('Participant ${event.remoteParticipant.identity} has joined the room');
//   event.remoteParticipant.onVideoTrackSubscribed.listen((RemoteVideoTrackSubscriptionEvent event) {
//     var mirror = false;
//     _widgets.add(event.remoteParticipant.widget(mirror));
//   });
// }

// _onParticipantDisconnected(RoomParticipantDisconnectedEvent event) async{
//   print('Participant ${event.remoteParticipant.identity} has left the room');
// }

// room.onRecordingStarted((Room room) {
//   print('Recording started in ${room.name}');
// });

// room.onRecordingStopped((Room room) {
//   print('Recording stopped in ${room.name}');
// });

  Future<void> disconnect() async {
    print('[ APPDEBUG ] ConferenceRoom.disconnect()');
    await _room!.disconnect();
  }

  void _onDisconnected(RoomDisconnectedEvent event) {
    print('[ APPDEBUG ] ConferenceRoom._onDisconnected');
  }

  void _onReconnecting(RoomReconnectingEvent room) {
    print('[ APPDEBUG ] ConferenceRoom._onReconnecting');
  }

  void _onConnected(Room room) {
    print('[ APPDEBUG ] ConferenceRoom._onConnected => state: ${room.state}');

    // When connected for the first time, add remote participant listeners
    _streamSubscriptions
        .add(_room!.onParticipantConnected.listen(_onParticipantConnected));
    _streamSubscriptions.add(
        _room!.onParticipantDisconnected.listen(_onParticipantDisconnected));
    final localParticipant = room.localParticipant;
    if (localParticipant == null) {
      print(
          '[ APPDEBUG ] ConferenceRoom._onConnected => localParticipant is null');
      return;
    }
// Get the first participant from the room.
    var remoteParticipant = room.remoteParticipants[0];
    print('RemoteParticipant ${remoteParticipant.identity} is in the room');
    // // Only add ourselves when connected for the first time too.
    _participants.add(BuildParticipant(
        widget: localParticipant.localVideoTracks[0].localVideoTrack.widget(),
        id: identity));

    for (final remoteParticipant in room.remoteParticipants) {
      var participant = _participants.firstWhereOrNull(
          (participant) => participant.id == remoteParticipant.sid);
      if (participant == null) {
        print(
            '[ APPDEBUG ] Adding participant that was already present in the room ${remoteParticipant.sid}, before I connected');
        _addRemoteParticipantListeners(remoteParticipant);
      }
    }
    // reload();
  }

  void _onConnectFailure(RoomConnectFailureEvent event) {
    print('[ APPDEBUG ] ConferenceRoom._onConnectFailure: ${event.exception}');
  }

  void _onParticipantConnected(RoomParticipantConnectedEvent event) {
    print(
        '[ APPDEBUG ] ConferenceRoom._onParticipantConnected, ${event.remoteParticipant.sid}');
    // _addRemoteParticipantListeners(event.remoteParticipant);
    print(
        '[ APPDEBUG ] ConferenceRoom._onParticipantConnected, ${event.remoteParticipant.identity}');
    _addRemoteParticipantListeners(event.remoteParticipant);
    // reload();
  }

  void _onParticipantDisconnected(RoomParticipantDisconnectedEvent event) {
    print(
        '[ APPDEBUG ] ConferenceRoom._onParticipantDisconnected: ${event.remoteParticipant.sid}');
    print(
        '[ APPDEBUG ] ConferenceRoom._onParticipantDisconnected: ${event.remoteParticipant.identity}');
    // _participants.removeWhere(
    //     (ParticipantWidget p) => p.id == event.remoteParticipant.sid);
    // reload();
  }

  void _addRemoteParticipantListeners(RemoteParticipant remoteParticipant) {
    _streamSubscriptions.add(remoteParticipant.onVideoTrackSubscribed
        .listen(_addOrUpdateParticipant));
    _streamSubscriptions.add(remoteParticipant.onAudioTrackSubscribed
        .listen(_addOrUpdateParticipant));
  }

  void _addOrUpdateParticipant(RemoteParticipantEvent event) {
    print(
        '[ APPDEBUG ] ConferenceRoom._addOrUpdateParticipant(), ${event.remoteParticipant.sid}');
    final participant = _participants.firstWhereOrNull(
      (BuildParticipant participant) =>
          participant.id == event.remoteParticipant.sid,
    );

    if (participant != null) {
      print(
          '[ APPDEBUG ] Participant found: ${participant.id}, updating A/V enabled values');
    } else {
      if (event is RemoteVideoTrackSubscriptionEvent) {
        print(
            '[ APPDEBUG ] New participant, adding: ${event.remoteParticipant.sid}');
        _participants.insert(
          0,
          BuildParticipant(
            widget: event.remoteVideoTrack.widget(),
            id: event.remoteParticipant.sid!,
          ),
        );
        // reload();
      }
    }
  }

  // Room _room;
  // final Completer<Room> _completer = Completer<Room>();

  // void _onConnected(Room room) {
  //   print('Connected to ${room.name}');
  //   _completer.complete(_room);
  // }

  // void _onConnectFailure(RoomConnectFailureEvent event) {
  //   print(
  //       'Failed to connect to room ${event.room.name} with exception: ${event.exception}');
  //   _completer.completeError(event.exception);
  // }

}
