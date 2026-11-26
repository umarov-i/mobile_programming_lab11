import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_api.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._api) : super(const SearchIdle()) {
    // A new SearchSubmitted cancels the handler of the previous one.
    on<SearchSubmitted>(_onSubmitted, transformer: restartable());
    on<SearchCleared>((event, emit) => emit(const SearchIdle()));
  }

  final ProductApi _api;

  Future<void> _onSubmitted(SearchSubmitted event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchIdle());
      return;
    }
    emit(const SearchLoading());
    try {
      // T15: temporarily use  _api.search(query, delayMs: 3000)
      final page = await _api.search(query);
      emit(page.products.isEmpty ? SearchEmpty(query) : SearchResults(page.products));
    } on ApiException catch (e) {
      emit(SearchError(e.message));
    }
  }
}
