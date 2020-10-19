import 'dispose_bag/base_dispose_bag.dart';

abstract class ViewModelType<I, O> {
  O transform(I input, [DisposeBag bag]) {}
}