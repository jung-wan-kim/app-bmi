import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 성능 최적화된 리스트 위젯
/// 큰 데이터셋에 대해 효율적인 렌더링과 메모리 관리 제공
class OptimizedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? separatorBuilder;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollController? controller;
  final int? itemExtent;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  
  const OptimizedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.controller,
    this.itemExtent,
    this.addAutomaticKeepAlives = false,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  });

  @override
  State<OptimizedList<T>> createState() => _OptimizedListState<T>();
}

class _OptimizedListState<T> extends State<OptimizedList<T>> {
  late ScrollController _scrollController;
  final Set<int> _visibleIndices = {};
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
  
  void _onScroll() {
    // 스크롤 성능 최적화를 위한 visible indices 추적
    // 실제 구현에서는 viewport 계산 로직 필요
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.separatorBuilder != null) {
      return ListView.separated(
        controller: _scrollController,
        physics: widget.physics,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        itemCount: widget.items.length,
        separatorBuilder: (context, index) => widget.separatorBuilder!,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            child: widget.itemBuilder(context, widget.items[index], index),
          );
        },
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.items.length,
      itemExtent: widget.itemExtent?.toDouble(),
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: widget.itemBuilder(context, widget.items[index], index),
        );
      },
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
    );
  }
}

/// 페이지네이션을 지원하는 최적화된 리스트
class PaginatedOptimizedList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? separatorBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final int pageSize;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  
  const PaginatedOptimizedList({
    super.key,
    required this.onLoadMore,
    required this.itemBuilder,
    this.separatorBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.pageSize = 20,
    this.physics,
    this.padding,
  });

  @override
  State<PaginatedOptimizedList<T>> createState() => _PaginatedOptimizedListState<T>();
}

class _PaginatedOptimizedListState<T> extends State<PaginatedOptimizedList<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      final newItems = await widget.onLoadMore(0, widget.pageSize);
      setState(() {
        _items.clear();
        _items.addAll(newItems);
        _hasMore = newItems.length >= widget.pageSize;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newItems = await widget.onLoadMore(_currentPage, widget.pageSize);
      setState(() {
        _items.addAll(newItems);
        _hasMore = newItems.length >= widget.pageSize;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && !_isLoading) {
      return Center(
        child: widget.emptyWidget ?? const Text('데이터가 없습니다'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: OptimizedList<T>(
        controller: _scrollController,
        items: _items,
        physics: widget.physics,
        padding: widget.padding,
        separatorBuilder: widget.separatorBuilder,
        itemBuilder: (context, item, index) {
          // 마지막 아이템에 로딩 인디케이터 추가
          if (index == _items.length - 1 && _isLoading) {
            return Column(
              children: [
                widget.itemBuilder(context, item, index),
                if (widget.separatorBuilder != null) widget.separatorBuilder!,
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.loadingWidget ?? 
                      const CircularProgressIndicator(),
                ),
              ],
            );
          }
          
          return widget.itemBuilder(context, item, index);
        },
      ),
    );
  }
}