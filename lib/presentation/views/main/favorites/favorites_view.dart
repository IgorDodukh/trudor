// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/router/app_router.dart';
import 'package:spoto/core/util/price_handler.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/widgets/adaptive_alert_dialog.dart';
import 'package:spoto/presentation/widgets/input_form_button.dart';

import '../../../../core/constant/images.dart';
import '../../../../core/error/failures.dart';
import '../../../blocs/favorites/favorites_bloc.dart';
import '../../../widgets/list_view_item_card.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final ScrollController scrollController = ScrollController();

  void _scrollListener() {
    double maxScroll = scrollController.position.maxScrollExtent;
    double currentScroll = scrollController.position.pixels;
    double scrollPercentage = 0.7;
    if (currentScroll > (maxScroll * scrollPercentage)) {
      if (context.read<FavoritesBloc>().state is FavoritesLoaded) {
        context.read<FavoritesBloc>().add(const GetFavorites());
      }
    }
  }

  void _loadProducts() {
    context.read<FavoritesBloc>().add(const GetFavorites());
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: (MediaQuery.of(context).padding.top + 10),
                ),
                const Text(favoritesTitle, style: TextStyle(fontSize: 24)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BlocBuilder<FavoritesBloc, FavoritesState>(
                      builder: (context, state) {
                        if (state is FavoritesLoading &&
                            state.favorites.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        if (state is FavoritesError &&
                            state.favorites.isEmpty) {

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (context.read<UserBloc>().state
                                  is UserLogged) ...[
                                if (state.failure is NetworkFailure)
                                  Image.asset(kNoConnection),
                                if (state.failure is ServerFailure)
                                  Image.asset(kInternalServerError),
                                if (state.failure is ExceptionFailure)
                                  Image.asset(kInternalServerError),
                                Text(state.failure.toString()),
                                const Text(noFavoritesYet),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                ),
                                IconButton(
                                    onPressed: () {
                                      final userId = (context
                                              .read<UserBloc>()
                                              .state
                                              .props
                                              .first as UserModel)
                                          .id;
                                      context
                                          .read<FavoritesBloc>()
                                          .add(GetFavorites(userId: userId));
                                    },
                                    icon: const Icon(Icons.refresh)),
                              ] else ...[
                                Image.asset(noFavoritesAsset),
                                const Center(
                                    child: Text(
                                  addFavoritesWithoutLogin,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                )),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                ),
                              ],
                            ],
                          );
                        }
                        if (state.favorites.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(noFavoritesAsset),
                              const Center(
                                  child: Text(
                                noFavoritesYet,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              )),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                              ),
                            ],
                          );
                        }
                        return ListView.builder(
                          itemCount: state.favorites.length < 11
                              ? state.favorites.length
                              : state.favorites.length +
                                  ((state is FavoritesLoading) ? 10 : 0),
                          padding: EdgeInsets.only(
                              top: (MediaQuery.of(context).padding.top - 30),
                              bottom:
                                  MediaQuery.of(context).padding.bottom + 200),
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            if (state is FavoritesLoading &&
                                state.favorites.isEmpty) {
                              return const ListViewItemCard(isFavorite: true);
                            } else {
                              if (state.favorites.length < index) {
                                return const ListViewItemCard(isFavorite: true);
                              }
                              return ListViewItemCard(
                                  listViewItem: state.favorites[index],
                                  isFavorite: true);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
