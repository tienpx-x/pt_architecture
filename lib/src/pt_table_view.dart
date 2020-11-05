import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef RefreshCallback = Future<void> Function();

class PTTableView extends StatefulWidget {
  final int scrollOffset;
  final BehaviorSubject<bool> isLoadingMore;
  final BehaviorSubject<bool> isRefreshing;
  final VoidCallback onLoadMore;
  final RefreshCallback onRefresh;
  final Widget child;
  final Widget indicator;

  const PTTableView({
    Key key,
    this.scrollOffset = 0,
    this.onLoadMore,
    this.onRefresh,
    this.isLoadingMore,
    this.isRefreshing,
    this.indicator,
    @required this.child,
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
              Expanded(child: widget.child),
              _buildIndicator(),
            ],
          ),
          onRefresh: widget.onRefresh,
        ),
        onNotification: _handleLoadMoreScroll,
      );
    } else if (widget.onRefresh != null) {
      return RefreshIndicator(
        child: widget.child,
        onRefresh: widget.onRefresh,
      );
    } else if (widget.onLoadMore != null) {
      return NotificationListener<ScrollNotification>(
        child: Column(
          children: [Expanded(child: widget.child), _buildIndicator()],
        ),
        onNotification: _handleLoadMoreScroll,
      );
    }
    return widget.child;
  }

  Widget _buildIndicator() {
    return StreamBuilder<bool>(
        stream: widget.isLoadingMore,
        builder: (context, snapshot) {
          if (snapshot.data) {
            if (widget.indicator == null) {
              return Container(
                width: 55,
                height: 55,
                padding: EdgeInsets.all(15),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            } else {
              return widget.indicator;
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
