part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
}

class GetFavorites extends FavoritesEvent {
  final String? userId;
  const GetFavorites({this.userId});

  @override
  List<Object> get props => [];
}

class AddProduct extends FavoritesEvent {
  final ListViewItem favoritesItem;
  const AddProduct({required this.favoritesItem});

  @override
  List<Object> get props => [];
}

class RemoveProduct extends FavoritesEvent {
  final ListViewItem favoritesItem;
  const RemoveProduct({required this.favoritesItem});

  @override
  List<Object> get props => [];
}

class ClearFavorites extends FavoritesEvent {
  const ClearFavorites();
  @override
  List<Object> get props => [];
}
