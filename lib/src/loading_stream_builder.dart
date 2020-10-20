import 'package:flutter/material.dart';

class LoadingStreamBuilder extends StreamBuilder<bool> {
  final int width;
  final int height;
  final int indicatorColor;
  final int indicatorStrokeWidth;
  final double opacity;
  final Widget child;

  LoadingStreamBuilder({
    Key key,
    Stream<bool> stream,
    this.width,
    this.height,
    this.indicatorColor,
    this.indicatorStrokeWidth,
    this.opacity,
    @required this.child,
  })  : assert(child != null),
        super(
          key: key,
          initialData: false,
          stream: stream,
          builder: (context, snapshot) {
            return Stack(
              children: [
                child,
                if (snapshot.data)
                  Material(
                    color: Colors.black.withOpacity(opacity ?? 0.3),
                    child: Center(
                      child: Container(
                        width: width ?? 40,
                        height: height ?? 40,
                        child: CircularProgressIndicator(
                          strokeWidth: indicatorStrokeWidth ?? 3,
                          backgroundColor: Colors.transparent,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              indicatorColor ?? Color(0xFF009FFF)),
                        ),
                      ),
                    ),
                  )
              ],
            );
          });
}
