import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spoto/core/constant/collections.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/constant/strings.dart';
import 'package:spoto/data/models/category/category_model.dart';
import 'package:spoto/data/models/product/price_tag_model.dart';
import 'package:spoto/data/models/product/product_model.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/domain/entities/favorites/favorites_item.dart';
import 'package:spoto/presentation/blocs/favorites/favorites_bloc.dart' as fav;
import 'package:spoto/presentation/blocs/product/product_bloc.dart' as prod;
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/widgets/adaptive_alert_dialog.dart';
import 'package:spoto/presentation/widgets/popup_card/hero_dialog_route.dart';

import '../../core/router/app_router.dart';
import '../views/product/add_product_form.dart';

class ListViewItemCard extends StatelessWidget {
  final ListViewItem? listViewItem;
  final Function? onFavoriteToggle;
  final Function? onClick;
  final Function()? onLongClick;
  final bool isSelected;
  final bool isFavorite;
  final bool isOwned;

  const ListViewItemCard({
    Key? key,
    this.listViewItem,
    this.onFavoriteToggle,
    this.onClick,
    this.onLongClick,
    this.isSelected = false,
    this.isFavorite = false,
    this.isOwned = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: listViewItem == null
          ? Shimmer.fromColors(
              highlightColor: Colors.white,
              baseColor: Colors.grey.shade100,
              child: buildBody(context),
            )
          : buildBody(context),
    );
  }

  Widget renewProductButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.restore_outlined, color: Colors.black, size: 36),
      onPressed: () async {
        return showDialog(
          context: context,
          builder: (context) {
            return RenewProductAlert(
              onRenewProduct: () async {
                final updatedModel = ProductModel(
                    id: listViewItem!.product.id,
                    ownerId: listViewItem!.product.ownerId,
                    name: listViewItem!.product.name,
                    description: listViewItem!.product.description,
                    isNew: listViewItem!.product.isNew,
                    status: ProductStatus.active,
                    priceTags: [
                      PriceTagModel(
                          id: '1',
                          name: "base",
                          price: int.parse(listViewItem!
                              .product.priceTags.first.price
                              .toString()))
                    ],
                    categories: [
                      CategoryModel.fromEntity(
                          listViewItem!.product.categories.first)
                    ],
                    category: listViewItem!.product.category,
                    images: listViewItem!.product.images,
                    createdAt: listViewItem!.product.createdAt,
                    updatedAt: DateTime.now());
                context
                    .read<prod.ProductBloc>()
                    .add(prod.UpdateProduct(updatedModel));
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  Widget deactivateProductButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close_rounded, color: Colors.black, size: 36),
      onPressed: () async {
        return showDialog(
          context: context,
          builder: (context) {
            return DeactivateProductAlert(
              onDeactivateProduct: () async {
                final updatedModel = ProductModel(
                    id: listViewItem!.product.id,
                    ownerId: listViewItem!.product.ownerId,
                    name: listViewItem!.product.name,
                    description: listViewItem!.product.description,
                    isNew: listViewItem!.product.isNew,
                    status: ProductStatus.inactive,
                    priceTags: [
                      PriceTagModel(
                          id: '1',
                          name: "base",
                          price: int.parse(listViewItem!
                              .product.priceTags.first.price
                              .toString()))
                    ],
                    categories: [
                      CategoryModel.fromEntity(
                          listViewItem!.product.categories.first)
                    ],
                    category: listViewItem!.product.category,
                    images: listViewItem!.product.images,
                    createdAt: listViewItem!.product.createdAt,
                    updatedAt: DateTime.now());
                context
                    .read<prod.ProductBloc>()
                    .add(prod.UpdateProduct(updatedModel));
              },
            );
          },
        );
      },
    );
  }

  Widget editProductButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return AddProductForm(productInfo: listViewItem!.product);
        }));
        // Navigator.of(context).pushNamed(AppRouter.editProduct,
        //     arguments: listViewItem!.product);
      },
      icon: const Icon(Icons.edit),
    );
  }

  Widget removeFromFavoritesButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        final userId =
            (context.read<UserBloc>().state.props.first as UserModel).id;
        context.read<fav.FavoritesBloc>().add(fav.RemoveProduct(
            favoritesItem: ListViewItem(
                product: listViewItem!.product,
                userId: userId,
                priceTag: listViewItem!.priceTag)));
        EasyLoading.showSuccess(removedFromFavoritesTitle);
      },
      icon: const Icon(Icons.favorite),
    );
  }

  Widget buildBody(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (listViewItem != null) {
          Navigator.of(context).pushNamed(AppRouter.productDetails,
              arguments: listViewItem!.product);
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
                    child: listViewItem == null
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
                              imageUrl: listViewItem!.product.images.isNotEmpty
                                  ? listViewItem!.product.images.first
                                  : noImagePlaceholder,
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
                          child: listViewItem == null
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
                                    listViewItem!.product.name,
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
                            child: listViewItem == null
                                ? Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  )
                                : Text(
                                    r'$' +
                                        listViewItem!.priceTag.price.toString(),
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
              child: isOwned
                  ? Row(
                      children: [
                        editProductButton(context),
                        listViewItem != null &&
                                listViewItem!.product.status ==
                                    ProductStatus.active
                            ? deactivateProductButton(context)
                            : renewProductButton(context),
                      ],
                    )
                  : isFavorite
                      ? removeFromFavoritesButton(context)
                      : IconButton(
                          onPressed: () {
                            final userId = (context
                                    .read<UserBloc>()
                                    .state
                                    .props
                                    .first as UserModel)
                                .id;
                            context.read<fav.FavoritesBloc>().add(
                                fav.AddProduct(
                                    favoritesItem: ListViewItem(
                                        product: listViewItem!.product,
                                        userId: userId,
                                        priceTag: listViewItem!.priceTag)));
                          },
                          icon: const Icon(Icons.favorite_border),
                        )),
        ],
      ),
    );
  }
}
