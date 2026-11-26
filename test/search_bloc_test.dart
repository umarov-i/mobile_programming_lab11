import 'package:api_catalog/bloc/search_bloc.dart';
import 'package:api_catalog/bloc/search_event.dart';
import 'package:api_catalog/bloc/search_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  blocTest<SearchBloc, SearchState>(
    "'phone': Loading then Results",
    build: () => SearchBloc(apiAnswering(200, pageJson())),
    act: (bloc) => bloc.add(const SearchSubmitted('phone')),
    expect: () => [isA<SearchLoading>(), isA<SearchResults>()],
  );

  blocTest<SearchBloc, SearchState>(
    'blank query: only Idle, no request',
    build: () => SearchBloc(apiAnswering(200, pageJson())),
    act: (bloc) => bloc.add(const SearchSubmitted(' ')),
    expect: () => [isA<SearchIdle>()],
  );

  blocTest<SearchBloc, SearchState>(
    'zero results: Loading then Empty (not Error)',
    build: () => SearchBloc(apiAnswering(200, {'products': [], 'total': 0, 'skip': 0, 'limit': 0})),
    act: (bloc) => bloc.add(const SearchSubmitted('zzzz')),
    expect: () => [isA<SearchLoading>(), isA<SearchEmpty>()],
  );
}
