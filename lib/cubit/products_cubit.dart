import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_api.dart';
import '../models/product.dart';

sealed class ProductsState {
  const ProductsState();
}

final class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

final class ProductsError extends ProductsState {
  const ProductsError(this.message);
  final String message;
}

final class ProductsLoaded extends ProductsState {
  const ProductsLoaded(
    this.products, {
    required this.total,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Product> products;
  final int total;
  final bool isLoadingMore;
  final String? loadMoreError;

  bool get hasMore => products.length < total;

  ProductsLoaded copyWith({bool? isLoadingMore, String? loadMoreError}) => ProductsLoaded(
        products,
        total: total,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreError: loadMoreError,
      );
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._api) : super(const ProductsLoading());

  final ProductApi _api;
  static const _pageSize = 20;

  /// [silent] keeps the current screen (no spinner), used by pull-to-refresh.
  Future<void> load({bool silent = false}) async {
    if (!silent) emit(const ProductsLoading());
    try {
      final page = await _api.getProducts(limit: _pageSize);
      if (isClosed) return;
      emit(ProductsLoaded(page.products, total: page.total));
    } on ApiException catch (e) {
      if (!isClosed) emit(ProductsError(e.message));
    }
  }

  Future<void> refresh() => load(silent: true);

  Future<void> loadMore() async {
    final current = state;
    // Guard: only from Loaded, only if more exist, never twice at once.
    if (current is! ProductsLoaded || !current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _api.getProducts(limit: _pageSize, skip: current.products.length);
      if (isClosed) return;
      emit(ProductsLoaded([...current.products, ...page.products], total: page.total));
    } on ApiException catch (e) {
      if (!isClosed) emit(current.copyWith(isLoadingMore: false, loadMoreError: e.message));
    }
  }
}
