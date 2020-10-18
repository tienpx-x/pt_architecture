import 'package:flutter_disposebag/flutter_disposebag.dart';

abstract class ViewModelType<I, O> {
  O transform([I input, DisposeBag bag]) {}
}
