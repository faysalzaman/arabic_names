part of 'names_bloc.dart';

abstract class NamesState {}

class NamesInitial extends NamesState {}

class NamesLoading extends NamesState {}

class NamesSuccess extends NamesState {
  final List<NameModel> names;
  final String query;
  NamesSuccess({required this.names, this.query = ''});
}

class NamesFailure extends NamesState {
  final Object error;
  NamesFailure(this.error);
}
