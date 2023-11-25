import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trudor/core/constant/strings.dart';
import 'package:trudor/data/models/user/user_model.dart';
import 'package:trudor/presentation/blocs/user/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../domain/entities/favorites/favorites_item.dart';
import '../../../../../domain/entities/product/price_tag.dart';
import '../../../../../domain/entities/product/product.dart';
import '../../blocs/favorites/favorites_bloc.dart';

class ProductDetailsView extends StatefulWidget {
  final Product product;
  const ProductDetailsView({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  int _currentIndex = 0;
  late PriceTag _selectedPriceTag;

  @override
  void initState() {
    _selectedPriceTag = widget.product.priceTags.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isFavorite = false;
    // bool isLoading = false;
    final favoritesState = context.read<FavoritesBloc>().state.favorites;
    for (var element in favoritesState) {
      if (element.product.id == widget.product.id) {
        isFavorite = true;
        break;
      }
    }
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
              items: widget.product.images.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Hero(
                      tag: widget.product.id,
                      child: CachedNetworkImage(
                        imageUrl: image.isEmpty ? noImagePlaceholder : image,
                        imageBuilder: (context, imageProvider) => Container(
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
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.grey,
                          ),
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
          // Padding(
          //   padding: const EdgeInsets.only(
          //     left: 20,
          //     right: 20,
          //   ),
          //   child: Wrap(
          //     children: widget.product.priceTags
          //         .map((priceTag) => GestureDetector(
          //               onTap: () {
          //                 setState(() {
          //                   _selectedPriceTag = priceTag;
          //                 });
          //               },
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                   border: Border.all(
          //                     width: _selectedPriceTag.id == priceTag.id
          //                         ? 2.0
          //                         : 1.0,
          //                     color: Colors.grey,
          //                   ),
          //                   borderRadius:
          //                       const BorderRadius.all(Radius.circular(5.0)),
          //                 ),
          //                 padding: const EdgeInsets.all(8),
          //                 margin: const EdgeInsets.only(right: 4),
          //                 child: Column(
          //                   children: [
          //                     Text(priceTag.name),
          //                     Text(priceTag.price.toString()),
          //                   ],
          //                 ),
          //               ),
          //             ))
          //         .toList(),
          //   ),
          // ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '\$${_selectedPriceTag.price}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 50,
              child: IconButton(
                onPressed: () {
                  final userId = (context.read<UserBloc>().state.props.first as UserModel).id;
                  if (isFavorite) {
                    context.read<FavoritesBloc>().add(RemoveProduct(
                        favoritesItem: FavoritesItem(
                            product: widget.product,
                            userId: userId,
                            priceTag: _selectedPriceTag)));

                  } else {
                    context.read<FavoritesBloc>().add(AddProduct(
                        favoritesItem: FavoritesItem(
                            product: widget.product,
                            userId: userId,
                            priceTag: _selectedPriceTag)));
                  }

                  setState(() {
                    isFavorite = !isFavorite;
                  });
                  Navigator.pop(context);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 36),
              ),
            ),
            // const SizedBox(
            //   width: 6,
            // ),
            // SizedBox(
            //   width: 90,
            //   child: InputFormButton(
            //     onClick: () {
            //       Navigator.of(context)
            //           .pushNamed(AppRouter.orderCheckout, arguments: [
            //         FavoritesItem(
            //           product: widget.product,
            //           priceTag: _selectedPriceTag,
            //         )
            //       ]);
            //     },
            //     titleText: "Buy",
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
