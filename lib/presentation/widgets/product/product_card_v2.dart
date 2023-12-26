import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/constant/strings.dart';
import 'package:spoto/core/router/app_router.dart';
import 'package:spoto/core/util/price_handler.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/domain/entities/favorites/favorites_item.dart';
import 'package:spoto/domain/entities/product/price_tag.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';

import '../../blocs/favorites/favorites_bloc.dart' as fav;

class ProductCardV2 extends StatefulWidget {
  final Product? product;
  final Function? onFavoriteToggle;
  final Function? onClick;

  const ProductCardV2({
    Key? key,
    this.product,
    this.onFavoriteToggle,
    this.onClick,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductCardV2State();
  }
}

class _ProductCardV2State extends State<ProductCardV2> {
  bool isFavorite = false;
  bool isLoading = false;
  String userId = "";
  late Timer? _loadingTimer;
  PriceTag? _selectedPriceTag;

  void setIsFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void _startLoadingTimer() {
    // Start the timer to simulate loading
    _loadingTimer = Timer(const Duration(seconds: 1), () {
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        // Set loading state back to false when loading is complete
        setIsLoading();
        setIsFavorite();
      }
      final popupMessage =
          isFavorite ? addedToFavoritesTitle : removedFromFavoritesTitle;
      EasyLoading.showSuccess(popupMessage);
    });
  }
  void addToFavorites() {
    setIsLoading();
    if (isFavorite) {
      context.read<fav.FavoritesBloc>().add(fav.RemoveProduct(
          favoritesItem: ListViewItem(
              product: widget.product!,
              userId: userId,
              priceTag: _selectedPriceTag!)));
    } else {
      context.read<fav.FavoritesBloc>().add(fav.AddProduct(
          favoritesItem: ListViewItem(
              product: widget.product!,
              userId: userId,
              priceTag: _selectedPriceTag!)));
    }
    _startLoadingTimer();
  }

  Widget favoritesButtonLoading() {
    // Display loading spinner when isLoading is true
    return isLoading
        ? const SizedBox(
            height: 52.0,
            width: 52.0,
            child: Center(
                child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.white,
            )),
          )
        : Container();
  }

  @override
  void initState() {
    super.initState();
    if (context.read<UserBloc>().state is UserLogged) {
      setState(() {
        userId = (context.read<UserBloc>().state.props.first as UserModel).id;
      });
    }

    if (widget.product != null) {
      _selectedPriceTag = widget.product!.priceTags.first;
    }

    final favoritesState = context.read<fav.FavoritesBloc>().state.favorites;
    for (var element in favoritesState) {
      if (widget.product != null && element.product.id == widget.product!.id) {
        setState(() {
          isFavorite = true;
        });
        break;
      }
    }
    _loadingTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: widget.product == null
          ? Shimmer.fromColors(
              baseColor: Colors.grey.shade100,
              highlightColor: Colors.white,
              child: buildBody(context),
            )
          : buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.product != null) {
          Navigator.of(context)
              .pushNamed(AppRouter.productDetails, arguments: widget.product);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
            width: MediaQuery.of(context).size.width / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4,
                  // offset: Offset(4, 8), // Shadow position
                ),
              ],
            ),
            child: Card(
              color: Colors.white,
              elevation: 2,
              surfaceTintColor: Colors.white,
              margin: const EdgeInsets.all(4),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: widget.product == null
                  ? Material(
                      child: GridTile(
                        footer: Container(),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Container(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    )
                  : Hero(
                      tag: widget.product!.id,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            bottom: 77,
                            child: CachedNetworkImage(
                              imageUrl: widget.product!.images.isNotEmpty
                                  ? widget.product!.images.first
                                  : noImagePlaceholder,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade100,
                                highlightColor: Colors.white,
                                child: Container(),
                              ),
                              errorWidget: (context, url, error) => Center(
                                  child: CachedNetworkImage(
                                      imageUrl: noImagePlaceholder)),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                // borderRadius: BorderRadius.circular(16),
                                color: Colors.black87,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 0,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 18,
                                            child: Text(
                                              jsonDecode(widget.product!
                                                  .location)["areaLvl3"],
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                  Expanded(
                                    flex: 0,
                                    child: SizedBox(
                                      height: 24,
                                      child: Text(
                                        widget.product!.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${NumberHandler.formatPrice(widget.product!.priceTags.first.price)} €',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isLoading
                              ? Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: favoritesButtonLoading())
                              : Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    onPressed: () {
                                      addToFavorites();
                                    },
                                    icon: Icon(
                                      isFavorite
                                          ? CupertinoIcons.heart_fill
                                          : CupertinoIcons.heart,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
            ),
          )),
        ],
      ),
    );
  }
}
