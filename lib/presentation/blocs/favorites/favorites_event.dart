part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
}

class GetFavorites extends FavoritesEvent {
  const GetFavorites();

  @override
  List<Object> get props => [];
}

class AddProduct extends FavoritesEvent {
  final FavoritesItem favoritesItem;
  const AddProduct({required this.favoritesItem});

  @override
  List<Object> get props => [];
}

class RemoveProduct extends FavoritesEvent {
  final FavoritesItem favoritesItem;
  const RemoveProduct({required this.favoritesItem});

  @override
  List<Object> get props => [];
}

class ClearFavorites extends FavoritesEvent {
  const ClearFavorites();
  @override
  List<Object> get props => [];
}
