part of 'names_bloc.dart';

abstract class NamesEvent {}

/// Opens a list (e.g. trending boys). Resets any previous search.
class LoadNames extends NamesEvent {
  final NameCategory category;
  final NameGender gender;
  LoadNames({required this.category, required this.gender});
}

/// Filters the currently opened list. An empty query shows everything.
class SearchNames extends NamesEvent {
  final String query;
  SearchNames(this.query);
}
