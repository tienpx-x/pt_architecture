import 'package:flutter/material.dart';

class PTStreamBuilder<T> extends StreamBuilder<T> {
  final AsyncWidgetBuilder<T> builder;
  final T initialData;

  const PTStreamBuilder({
    Key key,
    this.initialData,
    Stream<T> stream,
    @required this.builder,
  })  : assert(builder != null),
        super(
            key: key,
            initialData: initialData,
            stream: stream,
            builder: builder);

  @override
  Widget build(BuildContext context, AsyncSnapshot<T> currentSummary) {
    return Container(
      child:
          currentSummary.data != null ? builder(context, currentSummary) : null,
    );
  }
}
