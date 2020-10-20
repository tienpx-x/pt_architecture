import 'package:pt_architecture/src/dispose_bag/dispose_bag.dart';
import 'package:rxdart/rxdart.dart';

class Result<T> {
  T data;
  bool isLoading = false;
  Exception error;

  Result({this.data, this.isLoading, this.error});
}

extension ResultExtension<T> on Stream<T> {
  Stream<Result<T>> composeResult(DisposeBag bag) {
    var subject = PublishSubject<Result<T>>();
    this.listen((data) {
      subject.add(Result(data: data, isLoading: false));
    }, onError: (e) {
      subject.add(Result(data: null, error: e, isLoading: false));
    });
    return subject.startWith(Result(data: null, isLoading: true, error: null));
  }
}
