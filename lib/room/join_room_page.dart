import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../classes/join_room_base_class.dart';
import '../conference/conference_cubit.dart';
import '../conference/conference_page.dart';
import '../cubit/base_states.dart';
import '../cubit/cubit_provider.dart';
import 'join_room_cubit.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({Key? key}) : super(key: key);

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  TextEditingController nameController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return CubitProvider<CubitBaseState, JoinRoomCubit>(
        create: (context) => JoinRoomCubit(),
        listener: (context, state) async {
          if (state is RoomLoaded) {
            await Navigator.of(context).push(
              MaterialPageRoute<ConferencePage>(
                  fullscreenDialog: true,
                  builder: (BuildContext context) =>
                      // ConferencePage(roomModel: bloc),
                      BlocProvider(
                        create: (BuildContext context) => ConferenceCubit(
                          identity: state.identity,
                          token: state.token,
                          name: state.name,
                        ),
                        child: ConferencePage(),
                      )),
            );
          }
        },
        builder: (context, state, bloc) => Scaffold(
              backgroundColor: Colors.yellow,
              appBar: AppBar(
                backgroundColor: Colors.red,
                title: const Text(
                  'Twilio Video Chat',
                  style: TextStyle(color: Colors.yellow),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, color: Colors.red), //<-- SEE HERE
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 3, color: Colors.red), //<-- SEE HERE
                          ),
                          labelText: 'Name',
                          labelStyle: TextStyle(
                              fontSize: 20.0,
                              color: Color.fromARGB(255, 2, 157, 7)),
                          hintText: 'Enter Name',
                          hintStyle: TextStyle(
                              fontSize: 20.0,
                              color: Color.fromARGB(255, 39, 126, 197)),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        bloc.submit(nameController.text.toString());
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 20,
                        onPrimary: Colors.black87,
                        primary: Colors.grey[300],
                        minimumSize: const Size(88, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                      child: const Text('Join'),
                    )
                  ],
                ),
              ),
            ));
  }
}
