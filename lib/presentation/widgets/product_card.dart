import 'package:cached_network_image/cached_network_image.dart';
import 'package:spoto/core/constant/strings.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spoto/core/util/price_handler.dart';

import '../../core/router/app_router.dart';
import '../../domain/entities/product/product.dart';

class ProductCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: product == null
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
        if (product != null) {
          Navigator.of(context)
              .pushNamed(AppRouter.productDetails, arguments: product);
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: product == null
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
                      tag: product!.id,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: CachedNetworkImage(
                          imageUrl: product!.images.isNotEmpty ? product!.images.first : noImagePlaceholder,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade100,
                            highlightColor: Colors.white,
                            child: Container(),
                          ),
                          errorWidget: (context, url, error) =>
                              Center(child: CachedNetworkImage(imageUrl: noImagePlaceholder)),
                        ),
                      ),
                    ),
            ),
          )),
          Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: SizedBox(
                height: 18,
                child: product == null
                    ? Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    : Text(
                        product!.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: Row(
              children: [
                SizedBox(
                  height: 18,
                  child: product == null
                      ? Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      : Text(
                          '${NumberHandler.formatPrice(product!.priceTags.first.price)} €',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
