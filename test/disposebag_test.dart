import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pt_architecture/pt_architecture.dart';

void main() {
  test('issue', () async {
    final bag = DisposeBag();

    final controller = StreamController<int>(
      onCancel: () => Future.delayed(
        const Duration(milliseconds: 10),
      ),
    );

    await controller.disposedBy(bag);
    await controller.stream.listen(null).disposedBy(bag);

    await Stream.periodic(const Duration(milliseconds: 1), (i) => i)
        .map((i) => i + 1)
        .where((i) => i.isEven)
        .listen(controller.add)
        .disposedBy(bag);

    await bag.dispose();
  });
}