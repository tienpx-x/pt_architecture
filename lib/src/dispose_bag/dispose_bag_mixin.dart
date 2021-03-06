import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'base_dispose_bag.dart';

/// A mixin that provides the [DisposeBag] that helps disposing Streams and closing Sinks.
@optionalTypeArgs
mixin DisposeBagMixin<T extends StatefulWidget> on State<T> {
  DisposeBag _bag;
  Completer<bool> _mockBagDisposed;

  /// Set mock [DisposeBag] for testing purpose.
  /// Returns a [Future] that completes when [DisposeBag.dispose] completes.
  @visibleForTesting
  Future<bool> setMockBag(DisposeBag bag) {
    _bag = bag;
    return (_mockBagDisposed = Completer<bool>()).future;
  }

  @protected
  DisposeBag get bag {
    if (!mounted) {
      throw StateError('Invalid when getting bag after disposed.');
    }
    return _bag ??= DisposeBag();
  }

  @override
  void dispose() {
    final future = _bag?.dispose();

    if (future != null && _mockBagDisposed != null) {
      _mockBagDisposed.complete(future);
    }

    super.dispose();
  }
}