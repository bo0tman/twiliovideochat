import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class BuildParticipant {
  BuildParticipant({required this.id, required this.widget});

  final String id;
  final Widget widget;
}
