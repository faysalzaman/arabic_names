import 'package:arabic_names/DataBase/names_repository.dart';
import 'package:arabic_names/Model/names_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'names_event.dart';
part 'names_state.dart';

class NamesBloc extends Bloc<NamesEvent, NamesState> {
  NamesBloc({NamesRepository? repository})
      : _repository = repository ?? NamesRepository.instance,
        super(NamesInitial()) {
    on<LoadNames>(_onLoad);
    on<SearchNames>(_onSearch);
  }

  final NamesRepository _repository;
  NameCategory _category = NameCategory.all;
  NameGender _gender = NameGender.male;

  // Handlers run concurrently; a newer request invalidates older ones so a slow,
  // stale query can never overwrite the latest result.
  int _request = 0;

  Future<void> _onLoad(LoadNames event, Emitter<NamesState> emit) async {
    final request = ++_request;
    _category = event.category;
    _gender = event.gender;
    emit(NamesLoading());
    try {
      final names = await _repository.getNames(category: _category, gender: _gender);
      if (request == _request) emit(NamesSuccess(names: names));
    } catch (error) {
      if (request == _request) emit(NamesFailure(error));
    }
  }

  Future<void> _onSearch(SearchNames event, Emitter<NamesState> emit) async {
    final request = ++_request;
    try {
      final names = await _repository.getNames(
        category: _category,
        gender: _gender,
        query: event.query,
      );
      if (request == _request) emit(NamesSuccess(names: names, query: event.query));
    } catch (error) {
      if (request == _request) emit(NamesFailure(error));
    }
  }
}
