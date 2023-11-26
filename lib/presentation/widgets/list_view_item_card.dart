import 'package:cached_network_image/cached_network_image.dart';
import 'package:trudor/core/constant/strings.dart';
import 'package:trudor/data/models/user/user_model.dart';
import 'package:trudor/domain/entities/favorites/favorites_item.dart';
import 'package:trudor/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:trudor/presentation/blocs/user/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/router/app_router.dart';

class ListViewItemCard extends StatelessWidget {
  final ListViewItem? favoritesItem;
  final Function? onFavoriteToggle;
  final Function? onClick;
  final Function()? onLongClick;
  final bool isSelected;

  const ListViewItemCard({
    Key? key,
    this.favoritesItem,
    this.onFavoriteToggle,
    this.onClick,
    this.onLongClick,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: favoritesItem == null
          ? Shimmer.fromColors(
              highlightColor: Colors.white,
              baseColor: Colors.grey.shade100,
              child: buildBody(context),
            )
          : buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (favoritesItem != null) {
          Navigator.of(context).pushNamed(AppRouter.productDetails,
              arguments: favoritesItem!.product);
        }
      },
      onLongPress: onLongClick,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade50,
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: favoritesItem == null
                        ? Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Container(
                              color: Colors.grey.shade300,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: favoritesItem!.product.images.first.isNotEmpty ? favoritesItem!.product.images.first : noImagePlaceholder,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  const Center(child: Icon(Icons.error)),
                            ),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 35, 0),
                        child: SizedBox(
                          // height: 18,
                          child: favoritesItem == null
                              ? Container(
                                  width: 150,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                )
                              : SizedBox(
                                  child: Text(
                                    favoritesItem!.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 18,
                            child: favoritesItem == null
                                ? Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  )
                                : Text(
                                    r'$' + favoritesItem!.priceTag.price.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Positioned(
            top: 10,
            right: 0,
            child:
            IconButton(
                    onPressed: () {
                      final userId = (context.read<UserBloc>().state.props.first as UserModel).id;
                      context.read<FavoritesBloc>().add(RemoveProduct(
                          favoritesItem: ListViewItem(
                              product: favoritesItem!.product,
                              userId: userId,
                              priceTag: favoritesItem!.priceTag)));
                    },
                    icon: const Icon(Icons.close)),
          ),
        ],
      ),
    );
  }
}
