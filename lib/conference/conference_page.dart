import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ConferencePage extends StatefulWidget {
  Widget video;
  ConferencePage({Key? key, required this.video}) : super(key: key);

  @override
  State<ConferencePage> createState() => _ConferencePageState();
}

class _ConferencePageState extends State<ConferencePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        _videoWidget(context, widget.video),
      ],
    )
        //   body: Stack(children: [
        //     Positioned(
        //         bottom: 60,
        //         child: IconButton(
        //           color: Colors.red,
        //           icon: Icon(
        //             Icons.call_end_sharp,
        //             color: Colors.white,
        //           ),
        //           onPressed: () async {},
        //         ))
        //   ]),
        );
  }

  Widget _videoWidget(BuildContext context, Widget widget) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (widget == null) {
      return Placeholder(
        fallbackWidth: width,
        fallbackHeight: height / 2.0,
      );
    }

    return SizedBox(
      width: width,
      height: height / 2.0,
      child: widget,
    );
  }
}
