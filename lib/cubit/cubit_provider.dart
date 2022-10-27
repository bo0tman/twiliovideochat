import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'base_cubit.dart';
import 'base_states.dart';

typedef TwilioBlocWidgetBuilder<S extends CubitBaseState,
        T extends TwilioBaseCubit>
    = Widget Function(BuildContext context, S state, T bloc);

class CubitProvider<S extends CubitBaseState, T extends TwilioBaseCubit<S>>
    extends StatelessWidget {
  final Create<T> create;
  final bool lazy;

  final TwilioBlocWidgetBuilder<S, T> builder;
  final BlocWidgetListener<S>? listener;

  final BlocBuilderCondition<S>? buildWhen;

  final BlocListenerCondition<S>? listenWhen;
  const CubitProvider({
    Key? key,
    required this.create,
    required this.builder,
    this.listener,
    this.buildWhen,
    this.listenWhen,
    this.lazy = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      lazy: lazy,
      create: create,
      child: BlocConsumer<T, S>(
        builder: (context, state) {
          final bloc = context.read<T>();
          return builder(context, state, bloc);
        },
        listener: (context, state) {
          listener!(context, state);
        },
        buildWhen: buildWhen,
        listenWhen: listenWhen,
      ),
    );
  }
}
