class PagingInfo<T> {
  int page;
  List<T> items;
  bool hasMorePages;

  PagingInfo(this.page, this.items, this.hasMorePages);
}
