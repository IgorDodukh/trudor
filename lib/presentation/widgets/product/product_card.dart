import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/constant/strings.dart';
import 'package:spoto/core/util/input_converter.dart';
import 'package:spoto/core/util/price_handler.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/domain/entities/favorites/favorites_item.dart';
import 'package:spoto/domain/entities/product/price_tag.dart';
import 'package:spoto/presentation/blocs/favorites/favorites_bloc.dart' as fav;
import 'package:spoto/presentation/blocs/user/user_bloc.dart';

import '../../../core/router/app_router.dart';
import '../../../domain/entities/product/product.dart';

class ProductCard extends StatefulWidget {
  final Product? product;
  final Function? onFavoriteToggle;
  final Function? onClick;

  const ProductCard({
    Key? key,
    this.product,
    this.onFavoriteToggle,
    this.onClick,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;
  bool isLoading = false;
  String userId = "";
  late Timer? _loadingTimer;
  PriceTag? _selectedPriceTag;
  final formatCurrency = NumberFormat.compactCurrency(
      decimalDigits: 2, symbol: " €", locale: "ca");

  @override
  void initState() {
    super.initState();
    final favoritesState = context.read<fav.FavoritesBloc>().state.favorites;
    for (var element in favoritesState) {
      if (widget.product != null && element.product.id == widget.product!.id) {
        setState(() {
          isFavorite = true;
        });
        break;
      }
    }

    if (context.read<UserBloc>().state is UserLogged) {
      setState(() {
        userId = (context.read<UserBloc>().state.props.first as UserModel).id;
      });
    }

    if (widget.product != null) {
      _selectedPriceTag = widget.product!.priceTags.first;
    }

    _loadingTimer = null;
  }

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

  Widget favoritesButtonLoading() {
    // Display loading spinner when isLoading is true
    return isLoading
        ? const SizedBox(
            height: 40.0,
            width: 40.0,
            child: Center(
                child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              backgroundColor: Colors.black,
            )),
          )
        : Container();
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

  void /**/ addToFavorites() {
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
              borderRadius: BorderRadius.circular(16),
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
              margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
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
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 18,
                  child: widget.product == null
                      ? Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      : Text(
                          // formatCurrency
                          //     .format(widget.product!.priceTags.first.price),
                          '${NumberHandler.compactPrice(widget.product!.priceTags.first.price)} €',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: favoritesButtonLoading())
                    : IconButton(
                        visualDensity: VisualDensity.compact,
                        iconSize: 22,
                        onPressed: () {
                          addToFavorites();
                        },
                        icon: Icon(
                          isFavorite
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: Colors.black,
                        ),
                      ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
              child: SizedBox(
                height: 18,
                child: widget.product == null
                    ? Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    : Text(
                        widget.product!.name.truncateTo(19),
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 14),
                      ),
              )),
          Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: SizedBox(
                height: 18,
                child: widget.product == null
                    ? Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    : Text(
                        jsonDecode(widget.product!.location)["areaLvl3"],
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
              )),
        ],
      ),
    );
  }
}
