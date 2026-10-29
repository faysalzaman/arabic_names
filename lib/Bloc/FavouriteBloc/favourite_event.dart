part of 'favourite_bloc.dart';

@immutable
abstract class FavouriteEvent {}

class GetFavourites extends FavouriteEvent {}

/// Adds the name to the favourites, or removes it when it is already there.
class ToggleFavourite extends FavouriteEvent {
  final NameModel model;
  ToggleFavourite(this.model);
}
