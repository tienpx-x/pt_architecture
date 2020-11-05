import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef RefreshCallback = Future<void> Function();

class PTTableView extends StatefulWidget {
  final int scrollOffset;
  final BehaviorSubject<bool> isLoadingMore;
  final BehaviorSubject<bool> isRefreshing;
  final BehaviorSubject<bool> isEmpty;
  final BehaviorSubject<bool> isLoading;
  final VoidCallback onLoadMore;
  final RefreshCallback onRefresh;
  final Widget child;
  final Widget loadingIndicator;
  final Widget loadingMoreIndicator;
  final Widget emptyView;

  const PTTableView({
    Key key,
    this.scrollOffset = 0,
    this.onLoadMore,
    this.onRefresh,
    this.isLoadingMore,
    this.isRefreshing,
    @required this.child,
    this.isEmpty,
    this.emptyView,
    this.isLoading,
    this.loadingIndicator,
    this.loadingMoreIndicator,
  })  : assert(child != null),
        super(key: key);

  @override
  _PTTableViewState createState() => _PTTableViewState();
}

class _PTTableViewState extends State<PTTableView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(PTTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onLoadMore != null && widget.onRefresh != null) {
      return NotificationListener<ScrollNotification>(
        child: RefreshIndicator(
          child: Column(
            children: [
              _buildLoadingIndicator(),
              _buildEmptyView(),
              Expanded(child: widget.child),
              _buildLoadingMoreIndicator()
            ],
          ),
          onRefresh: widget.onRefresh,
        ),
        onNotification: _handleLoadMoreScroll,
      );
    } else if (widget.onRefresh != null) {
      return RefreshIndicator(
        child: Column(
          children: [
            _buildLoadingIndicator(),
            _buildEmptyView(),
            Expanded(child: widget.child)
          ],
        ),
        onRefresh: widget.onRefresh,
      );
    } else if (widget.onLoadMore != null) {
      return NotificationListener<ScrollNotification>(
        child: Column(
          children: [
            _buildLoadingIndicator(),
            _buildEmptyView(),
            Expanded(child: widget.child),
            _buildLoadingMoreIndicator()
          ],
        ),
        onNotification: _handleLoadMoreScroll,
      );
    }
    return widget.child;
  }

  Widget _buildLoadingIndicator() {
    return StreamBuilder<bool>(
        stream: widget.isLoading,
        builder: (context, snapshot) {
          if (snapshot?.data ?? false) {
            if (widget.loadingIndicator == null) {
              return Container(
                width: 55,
                height: 55,
                padding: EdgeInsets.all(15),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            } else {
              return widget.loadingIndicator;
            }
          }
          return Container(width: 0, height: 0);
        });
  }

  Widget _buildEmptyView() {
    return StreamBuilder<bool>(
        initialData: false,
        stream: widget.isEmpty,
        builder: (context, snapshot) {
          if (snapshot?.data ?? false) {
            if (widget.emptyView != null) {
              return widget.emptyView;
            }
          }
          return Container(width: 0, height: 0);
        });
  }

  Widget _buildLoadingMoreIndicator() {
    return StreamBuilder<bool>(
        stream: widget.isLoadingMore,
        builder: (context, snapshot) {
          if (snapshot?.data ?? false) {
            if (widget.loadingMoreIndicator == null) {
              return Container(
                width: 55,
                height: 55,
                padding: EdgeInsets.all(15),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            } else {
              return widget.loadingMoreIndicator;
            }
          }
          return Container();
        });
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels - notification.metrics.maxScrollExtent >
          widget.scrollOffset) {
        if (!widget.isLoadingMore.value) {
          widget.onLoadMore();
        }
      }
    }
    return false;
  }
}
