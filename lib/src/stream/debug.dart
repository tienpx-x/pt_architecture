import 'package:rxdart/rxdart.dart';

extension DebugExtensions<T> on Stream<T> {
  Stream<T> debug([String streamName]) {
    var name = streamName ?? this.hashCode;
    return this.doOnListen(() {
      print("[$name] listened");
    }).doOnData((data) {
      print("[${name}] -> Event emit($data)");
    }).doOnError((e, s) {
      print("[$name] -> Event error(${e})");
    }).doOnDone(() {
      print("[${name}] done");
    }).doOnCancel(() {
      print("[${name}] dispose");
    });
  }
}
