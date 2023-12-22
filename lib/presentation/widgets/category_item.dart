import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:spoto/core/constant/collections.dart';
import 'package:spoto/presentation/blocs/filter/filter_cubit.dart';
import 'package:spoto/presentation/blocs/product/product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spoto/presentation/views/main/category/sub_category_view.dart';

import '../../domain/entities/category/category.dart';
import '../blocs/home/navbar_cubit.dart';

class CategoryItemCard extends StatefulWidget {
  // TODO: improve design of that cards
  final Category? category;
  ValueChanged<String>? onCategorySelected;

  CategoryItemCard({Key? key, this.category, this.onCategorySelected}) : super(key: key);

  @override
  State<CategoryItemCard> createState() => _CategoryItemCardState();
}

class _CategoryItemCardState extends State<CategoryItemCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onCategorySelected!(widget.category!.name);
        });
        Navigator.of(context).pop();
        if (widget.category != null) {
          // temporary disabled. add navigation to SubCategoryView with animation to the right inside the same ModalBottomSheet
          // Navigator.of(context).push(
          //   PageRouteBuilder(
          //     opaque: false,
          //     barrierDismissible: true,
          //     pageBuilder: (context, animation, secondaryAnimation) =>
          //         SubCategoryView(category: category!),
          //     transitionsBuilder:
          //         (context, animation, secondaryAnimation, child) {
          //       const begin = Offset(1.0, 0.0);
          //       const end = Offset.zero;
          //       const curve = Curves.ease;
          //       final tween = Tween(begin: begin, end: end).chain(
          //         CurveTween(curve: curve),
          //       );
          //       return SlideTransition(
          //         position: animation.drive(tween),
          //         child: child,
          //       );
          //     },
          //   ),
          // );
          // context.read<NavbarCubit>().controller.animateToPage(0,
          //     duration: const Duration(milliseconds: 400),
          //     curve: Curves.linear);
          // context.read<NavbarCubit>().update(0);
          // context.read<FilterCubit>().update(category: category);
          // context
          //     .read<ProductBloc>()
          //     .add(GetProducts(context.read<FilterCubit>().state));
        }
      },
      child: widget.category != null
          ? Stack(
              children: [
                Card(
                  color: Colors.grey.shade100,
                  margin: const EdgeInsets.only(bottom: 10, top: 0),
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox(
                    height: 55,
                    width: double.maxFinite,
                    child: Hero(
                      tag: widget.category!.id,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          backgroundBlendMode: BlendMode.multiply,
                          // gradient: LinearGradient(
                          //   colors: [Colors.black, Colors.black],
                          //   stops: [0.15, 0.85],
                          //   begin: Alignment.topLeft,
                          //   end: Alignment.bottomRight,
                          // ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    left: 45,
                    bottom: 19,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.category!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    )),
                // temporary disabled
                // const Positioned(
                //     right: 10,
                //     bottom: 24,
                //     child: Icon(
                //       Icons.arrow_forward_ios,
                //       color: Colors.white,
                //     )),
                Positioned(
                    left: 16,
                    bottom: 24,
                    child: Icon(
                      categoryIcon[widget.category!.name],
                      color: Colors.white,
                    )),
              ],
            )
          : Shimmer.fromColors(
              baseColor: Colors.grey.shade100,
              highlightColor: Colors.white70,
              child: Card(
                color: Colors.grey.shade100,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.18,
                ),
              ),
            ),
    );
  }
}
