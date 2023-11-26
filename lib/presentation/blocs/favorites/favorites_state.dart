part of 'favorites_bloc.dart';

abstract class FavoritesState extends Equatable {
  final List<ListViewItem> favorites;
  const FavoritesState({required this.favorites});
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial({required super.favorites});

  @override
  List<Object> get props => [];
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading({required super.favorites});

  @override
  List<Object> get props => [];
}

class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded({required super.favorites});

  @override
  List<Object> get props => [];
}

class FavoritesError extends FavoritesState {
  final Failure failure;
  const FavoritesError({
    required this.failure,
    required super.favorites});

  @override
  List<Object> get props => [];
}
