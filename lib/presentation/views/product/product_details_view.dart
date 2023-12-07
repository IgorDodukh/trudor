import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:spoto/core/constant/collections.dart';
import 'package:spoto/core/constant/images.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/constant/strings.dart';
import 'package:spoto/data/models/category/category_model.dart';
import 'package:spoto/data/models/product/price_tag_model.dart';
import 'package:spoto/data/models/product/product_model.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/widgets/adaptive_alert_dialog.dart';
import 'package:spoto/presentation/widgets/popup_card/add_product_floating_card.dart';
import 'package:spoto/presentation/widgets/popup_card/hero_dialog_route.dart';

import '../../../../../domain/entities/favorites/favorites_item.dart';
import '../../../../../domain/entities/product/price_tag.dart';
import '../../../../../domain/entities/product/product.dart';
import '../../blocs/favorites/favorites_bloc.dart' as fav;
import '../../blocs/product/product_bloc.dart' as prod;

class ProductDetailsView extends StatefulWidget {
  final Product product;

  const ProductDetailsView({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  int _currentIndex = 0;
  late PriceTag _selectedPriceTag;
  bool isFavorite = false;
  bool isLoading = false;
  bool isOwner = false;
  String userId = "";
  late Timer? _loadingTimer;

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

  void _cancelTimer() {
    // Cancel the timer if it's active and initialised
    if (_loadingTimer != null) {
      if (_loadingTimer!.isActive) {
        _loadingTimer!.cancel();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the timer if the widget is disposed
    _cancelTimer();
  }

  Widget favoritesButtonLoading() {
    // Display loading spinner when isLoading is true
    return isLoading
        ? const SizedBox(
            height: 52.0,
            width: 52.0,
            child: Center(
                child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              backgroundColor: Colors.yellowAccent,
            )),
          )
        : Container();
  }

  void addToFavorites() {
    setIsLoading();
    if (isFavorite) {
      context.read<fav.FavoritesBloc>().add(fav.RemoveProduct(
          favoritesItem: ListViewItem(
              product: widget.product,
              userId: userId,
              priceTag: _selectedPriceTag)));
    } else {
      context.read<fav.FavoritesBloc>().add(fav.AddProduct(
          favoritesItem: ListViewItem(
              product: widget.product,
              userId: userId,
              priceTag: _selectedPriceTag)));
    }
    _startLoadingTimer();
  }

  Widget renewProductButton() {
    return IconButton(
      icon: const Icon(Icons.restore_outlined, color: Colors.white, size: 36),
      onPressed: () async {
        return showDialog(
          context: context,
          builder: (context) {
            return RenewProductAlert(
              onRenewProduct: () async {
                final updatedModel = ProductModel(
                    id: widget.product.id,
                    ownerId: widget.product.ownerId,
                    name: widget.product.name,
                    description: widget.product.description,
                    isNew: widget.product.isNew,
                    status: ProductStatus.active,
                    priceTags: [
                      PriceTagModel(
                          id: '1',
                          name: "base",
                          price: int.parse(
                              widget.product.priceTags.first.price.toString()))
                    ],
                    categories: [
                      CategoryModel.fromEntity(widget.product.categories.first)
                    ],
                    category: widget.product.category,
                    images: widget.product.images,
                    createdAt: widget.product.createdAt,
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

  Widget deactivateProductButton() {
    return IconButton(
      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 36),
      onPressed: () async {
        return showDialog(
          context: context,
          builder: (context) {
            return DeactivateProductAlert(
              onDeactivateProduct: () async {
                final updatedModel = ProductModel(
                    id: widget.product.id,
                    ownerId: widget.product.ownerId,
                    name: widget.product.name,
                    description: widget.product.description,
                    isNew: widget.product.isNew,
                    status: ProductStatus.inactive,
                    priceTags: [
                      PriceTagModel(
                          id: '1',
                          name: "base",
                          price: int.parse(
                              widget.product.priceTags.first.price.toString()))
                    ],
                    categories: [
                      CategoryModel.fromEntity(widget.product.categories.first)
                    ],
                    category: widget.product.category,
                    images: widget.product.images,
                    createdAt: widget.product.createdAt,
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

  @override
  void initState() {
    if (context.read<UserBloc>().state is UserLogged) {
      setState(() {
        userId = (context.read<UserBloc>().state.props.first as UserModel).id;
      });
    }
    if (userId == widget.product.ownerId) {
      setState(() {
        isOwner = true;
      });
    }
    final favoritesState = context.read<fav.FavoritesBloc>().state.favorites;
    for (var element in favoritesState) {
      if (element.product.id == widget.product.id) {
        setState(() {
          isFavorite = true;
        });
        break;
      }
    }
    _loadingTimer = null;
    _selectedPriceTag = widget.product.priceTags.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.message)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).width,
            child: CarouselSlider(
              options: CarouselOptions(
                height: double.infinity,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                aspectRatio: 16 / 9,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: widget.product.images.isEmpty
                  ? [
                      Builder(
                        builder: (BuildContext context) {
                          return Hero(
                            tag: widget.product.id,
                            child: CachedNetworkImage(
                              imageUrl: noImagePlaceholder,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                        Colors.grey.shade50.withOpacity(0.25),
                                        BlendMode.softLight),
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ]
                  : widget.product.images.map((image) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Hero(
                            tag: widget.product.id,
                            child: CachedNetworkImage(
                              imageUrl:
                                  image.isEmpty ? noImagePlaceholder : image,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                        Colors.grey.shade50.withOpacity(0.25),
                                        BlendMode.softLight),
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                ),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Image.asset(kNoImageAvailable),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.center,
              child: AnimatedSmoothIndicator(
                activeIndex: _currentIndex,
                count: widget.product.images.length,
                effect: ScrollingDotsEffect(
                    dotColor: Colors.grey.shade300,
                    maxVisibleDots: 7,
                    activeDotColor: Colors.grey,
                    dotHeight: 6,
                    dotWidth: 6,
                    activeDotScale: 1.1,
                    spacing: 6),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 14, top: 20, bottom: 4),
            child: Text(
              widget.product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 10,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom),
            child: Text(
              widget.product.description,
              style: const TextStyle(fontSize: 14),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.secondary,
        height: 80 + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 10,
          top: 10,
          left: 20,
          right: 20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_selectedPriceTag.price} €',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                isOwner
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.product.status == ProductStatus.active
                              ? deactivateProductButton()
                              : renewProductButton(),
                          // deactivateProductButton(),
                        ],
                      )
                    : Container(),
                const SizedBox(width: 16),
                isOwner
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 36),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(HeroDialogRoute(builder: (context) {
                                return PopupCard(
                                    existingProduct: widget.product);
                              }));
                            },
                          ),
                        ],
                      )
                    : Container(),
                // Display loading spinner when isLoading is true
                favoritesButtonLoading(),
                const SizedBox(width: 16),
                // Display IconButton when not loading
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (widget.product.status == ProductStatus.active) {
                      if (state is UserLogged) {
                        return !isLoading
                            ? IconButton(
                                onPressed: () {
                                  addToFavorites();
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              )
                            : Container();
                      } else {
                        return IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const UnauthorisedAddFavoritesAlert();
                              },
                            );
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                            size: 36,
                          ),
                        );
                      }
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
