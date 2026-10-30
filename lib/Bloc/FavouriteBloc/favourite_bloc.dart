import 'package:arabic_names/DataBase/favourites_store.dart';
import 'package:arabic_names/DataBase/names_repository.dart';
import 'package:arabic_names/Model/names_model.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favourite_event.dart';
part 'favourite_state.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  FavouriteBloc({FavouritesStore? store, NamesRepository? repository})
      : _store = store ?? FavouritesStore.instance,
        _repository = repository ?? NamesRepository.instance,
        super(FavouriteInitial()) {
    on<GetFavourites>((event, emit) async => emit(await _load()));
    on<ToggleFavourite>((event, emit) async {
      await _store.toggle(event.model.key);
      emit(await _load());
    });
  }

  final FavouritesStore _store;
  final NamesRepository _repository;

  Future<FavouriteSuccess> _load() async {
    final keys = await _store.keys();
    return FavouriteSuccess(names: await _repository.getByKeys(keys));
  }
}
