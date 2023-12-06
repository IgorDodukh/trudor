import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:trudor/domain/usecases/favorites/remove_favorites_item_usecase.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/favorites/favorites_item.dart';
import '../../../domain/usecases/favorites/add_favorites_item_usecase.dart';
import '../../../domain/usecases/favorites/clear_favorites_usecase.dart';
import '../../../domain/usecases/favorites/get_cached_favorites_usecase.dart';
import '../../../domain/usecases/favorites/sync_favorites_usecase.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetCachedFavoritesUseCase _getCachedFavoritesUseCase;
  final AddFavoritesUseCase _addFavoritesUseCase;
  final SyncFavoritesUseCase _syncFavoritesUseCase;
  final ClearFavoritesUseCase _clearFavoritesUseCase;
  final RemoveFavoritesItemUseCase _removeFavoritesItemUseCase;
  FavoritesBloc(
    this._getCachedFavoritesUseCase,
    this._addFavoritesUseCase,
    this._syncFavoritesUseCase,
    this._clearFavoritesUseCase,
    this._removeFavoritesItemUseCase,
  ) : super(const FavoritesInitial(favorites: [])) {
    on<GetFavorites>(_onGetFavorites);
    on<AddProduct>(_onAddToFavorites);
    on<RemoveProduct>(_onRemoveFromFavorites);
    on<ClearFavorites>(_onClearFavorites);
  }

  void _onGetFavorites(GetFavorites event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading(favorites: state.favorites));
    try {
      final result = await _getCachedFavoritesUseCase(NoParams());
      result.fold(
        (failure) => emit(FavoritesError(favorites: state.favorites, failure: failure)),
        (favorites) => emit(FavoritesLoaded(favorites: favorites)),
      );
      final syncResult = await _syncFavoritesUseCase(NoParams());
      emit(FavoritesLoading(favorites: state.favorites));
      syncResult.fold(
        (failure) => emit(FavoritesError(favorites: state.favorites, failure: failure)),
        (favorites) => emit(FavoritesLoaded(favorites: favorites)),
      );
    } catch (e) {
      EasyLoading.showError("Failed to get Favorites: $e.\nState: $state");
      emit(FavoritesError(failure: ExceptionFailure(), favorites: state.favorites));
    }
  }

  void _onAddToFavorites(AddProduct event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading(favorites: state.favorites));
    try {
      List<ListViewItem> favorites = List.from(state.favorites);
      final index = favorites.indexWhere((favoritesItem) => favoritesItem.product.id == event.favoritesItem.product.id);
      if (index != -1) {
        print("Product is already in Favorites. Add removing from Favorites");
      } else {
        favorites.add(event.favoritesItem);
        var result = await _addFavoritesUseCase(event.favoritesItem);
        result.fold(
              (failure) => emit(FavoritesError(favorites: state.favorites, failure: failure)),
              (_) => emit(FavoritesLoaded(favorites: favorites)),
        );
      }
    } catch (e) {
      EasyLoading.showError("Failed to add Favorites: $e");
      emit(FavoritesError(favorites: state.favorites, failure: ExceptionFailure()));
    }
  }

  void _onRemoveFromFavorites(RemoveProduct event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading(favorites: state.favorites));
    try {
      List<ListViewItem> favorites = [];
      favorites.addAll(state.favorites);
      final indexToRemove = favorites.indexWhere((favoritesItem) => favoritesItem.product.id == event.favoritesItem.product.id);
      favorites.removeAt(indexToRemove);
      var result = await _removeFavoritesItemUseCase(event.favoritesItem);
      result.fold(
            (failure) => emit(FavoritesError(favorites: state.favorites, failure: failure)),
            (_) => emit(FavoritesLoaded(favorites: favorites)),
      );
    } catch (e) {
      EasyLoading.showError("Failed to remove Favorites: $e");
      emit(FavoritesError(favorites: state.favorites, failure: ExceptionFailure()));
    }  }

  void _onClearFavorites(ClearFavorites event, Emitter<FavoritesState> emit) async {
    try {
      emit(const FavoritesLoading(favorites: []));
      emit(const FavoritesLoaded(favorites: []));
      await _clearFavoritesUseCase(NoParams());
    } catch (e) {
      EasyLoading.showError("Failed to clear Favorites: $e");
      emit(FavoritesError(favorites: const [], failure: ExceptionFailure()));
    }
  }
}
