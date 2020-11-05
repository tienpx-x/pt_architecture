import 'package:flutter/cupertino.dart';
import 'package:pt_architecture/pt_architecture.dart';
import 'package:rxdart/rxdart.dart';

class GetPageResult<T> {
  Stream<PagingInfo<T>> item;
  Stream<void> fetch;
  Stream<bool> isLoading;
  Stream<bool> isReloading;
  Stream<bool> isLoadingMore;

  GetPageResult(
      {@required this.item,
      @required this.fetch,
      @required this.isLoading,
      @required this.isReloading,
      @required this.isLoadingMore});
}

class GetPageInputWithParams<Item, Input> {
  Stream<Input> loadTrigger;
  Stream<Input> reloadTrigger;
  Stream<Input> loadMoreTrigger;
  Stream<PagingInfo<Item>> Function(Input) getItems;
  Stream<PagingInfo<Item>> Function(Input, int) loadMoreItems;

  GetPageInputWithParams(
      {@required this.loadTrigger,
      @required this.reloadTrigger,
      @required this.loadMoreTrigger,
      @required this.getItems,
      @required this.loadMoreItems});
}

class GetPageInput<Item> {
  Stream<void> loadTrigger;
  Stream<void> reloadTrigger;
  Stream<void> loadMoreTrigger;
  Stream<PagingInfo<Item>> Function() getItems;
  Stream<PagingInfo<Item>> Function(int) loadMoreItems;

  GetPageInput(
      {@required this.loadTrigger,
      @required this.reloadTrigger,
      @required this.loadMoreTrigger,
      @required this.getItems,
      @required this.loadMoreItems});
}

extension Methods on ViewModelType {
  GetPageResult<Item> getPageWithParams<Item, Input>(
      GetPageInputWithParams<Item, Input> input) {
    var pageSubject =
        BehaviorSubject<PagingInfo<Item>>.seeded(PagingInfo(1, [], true));

    var isLoading = BehaviorSubject<bool>.seeded(false);
    var isReloading = BehaviorSubject<bool>.seeded(false);
    var isLoadingMore = BehaviorSubject<bool>.seeded(false);

    var isLoadingOrLoadingMore =
        Rx.merge([isLoading, isReloading, isLoadingMore])
            .startWith(false)
            .asBroadcastStream();

    var loadItems = input.loadTrigger
        .withLatestFrom(isLoadingOrLoadingMore, (t, s) => [t, s])
        .where((args) => !args[1])
        .switchMap((args) => input.getItems(args[0]).trackActivity(isLoading))
        .doOnData((data) => pageSubject.add(data))
        .mapTo<void>(null)
        .asBroadcastStream();

    var reloadItems = input.reloadTrigger
        .withLatestFrom(isLoadingOrLoadingMore, (t, s) => [t, s])
        .where((args) => !args[1])
        .switchMap((args) => input.getItems(args[0]).trackActivity(isReloading))
        .doOnData((data) => pageSubject.add(data))
        .mapTo<void>(null)
        .asBroadcastStream();

    var loadMoreItems = input.loadMoreTrigger
        .throttleTime(Duration(seconds: 1))
        .withLatestFrom(isLoadingOrLoadingMore, (t, s) => [t, s])
        .where((args) => !args[1])
        .withLatestFrom(pageSubject, (t, s) => [t, s])
        .where((args) => args[1].hasMorePages)
        .switchMap((args) {
          var param = args[0][0];
          var subject = args[1];
          var _page =
              subject.items.isNotEmpty ? subject.page + 1 : subject.page;
          return input.loadMoreItems(param, _page).trackActivity(isLoadingMore);
        })
        .withLatestFrom(pageSubject, (t, s) => [s, t])
        .doOnData((args) {
          var currentPage = args[0];
          var newPage = args[1];
          var newItems = currentPage.items + newPage.items;
          var page =
              PagingInfo<Item>(newPage.page, newItems, newPage.hasMorePages);
          pageSubject.add(page);
        })
        .mapTo<void>(null)
        .asBroadcastStream();

    var fetchItems = Rx.merge([loadItems, reloadItems, loadMoreItems]);

    return GetPageResult(
        item: pageSubject,
        fetch: fetchItems,
        isLoading: isLoading,
        isReloading: isReloading,
        isLoadingMore: isLoadingMore);
  }

  GetPageResult<Item> getPage<Item>(GetPageInput<Item> input) {
    return getPageWithParams(GetPageInputWithParams(
        loadTrigger: input.loadTrigger,
        reloadTrigger: input.reloadTrigger,
        loadMoreTrigger: input.loadMoreTrigger,
        getItems: (_) => input.getItems(),
        loadMoreItems: (_, page) => input.loadMoreItems(page)));
  }
}
