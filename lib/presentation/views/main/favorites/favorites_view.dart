import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spoto/core/constant/images.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/widgets/list_view_item_card.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  _FavoritesViewState createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const Text(favoritesTitle,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  if (state is FavoritesLoading && state.favorites.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (state is FavoritesError && state.favorites.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (context.read<UserBloc>().state is UserLogged) ...[
                          if (state.failure is NetworkFailure)
                            Image.asset(kNoConnection),
                          if (state.failure is ServerFailure)
                            Image.asset(kInternalServerError),
                          if (state.failure is ExceptionFailure)
                            Image.asset(kInternalServerError),
                          Text(state.failure.toString()),
                          const Text(
                            noFavoritesYet,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.black),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
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
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
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
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.black),
                        )),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
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
                        bottom: MediaQuery.of(context).padding.bottom + 200),
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
    ));
  }
}
