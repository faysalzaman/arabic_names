part of 'favourite_bloc.dart';

@immutable
abstract class FavouriteState {}

class FavouriteInitial extends FavouriteState {}

class FavouriteSuccess extends FavouriteState {
  /// Favourite names, newest first.
  final List<NameModel> names;

  /// Keys of [names], for O(1) "is this a favourite?" checks.
  final Set<String> keys;

  FavouriteSuccess({required this.names}) : keys = {for (final n in names) n.key};
}
