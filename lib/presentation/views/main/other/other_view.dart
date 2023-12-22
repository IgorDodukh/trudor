import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/util/firestore/firestore_products.dart';
import 'package:spoto/core/util/typesense/typesense_products.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/domain/usecases/product/get_product_usecase.dart';
import 'package:spoto/domain/usecases/product/update_product_usecase.dart';
import 'package:spoto/presentation/widgets/adaptive_alert_dialog.dart';

import '../../../../core/constant/images.dart';
import '../../../../core/router/app_router.dart';
import '../../../blocs/favorites/favorites_bloc.dart';
import '../../../blocs/user/user_bloc.dart';
import '../../../widgets/other_item_card.dart';

class OtherView extends StatelessWidget {
  const OtherView({Key? key}) : super(key: key);

  Widget updateTypesenseFirestore() {
    return OtherItemCard(
      onClick: () async {
        EasyLoading.show(status: loadingTitle, dismissOnTap: false);
        TypesenseProducts typesenseService = TypesenseProducts();
        FirestoreProducts firestoreService = FirestoreProducts();
        final products = await typesenseService
            .getProducts(const FilterProductParams(pageSize: 100));
        for (var product in products.products) {
          final productData = Product(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.priceTags[0].price,
            priceTags: product.priceTags,
            // categories: product.categories,
            category: product.category,
            images: product.images,
            createdAt: product.createdAt,
            updatedAt: product.updatedAt,
            ownerId: product.ownerId,
            isNew: product.isNew,
            status: product.status,
          );
          firestoreService.updateProduct(UpdateProductParams(
              product: productData, isPublicationsAction: false));
        }
        EasyLoading.dismiss();
        EasyLoading.showToast(
            "${products.toJson()['meta']["total"]} products found");
      },
      title: "Update Typesense & Firestore",
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLogged) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.userProfile,
                        arguments: state.user,
                      );
                    },
                    child: Row(
                      children: [
                        state.user.image != null
                            ? CachedNetworkImage(
                                imageUrl: state.user.image!,
                                imageBuilder: (context, image) => CircleAvatar(
                                  radius: 36.0,
                                  backgroundImage: image,
                                  backgroundColor: Colors.transparent,
                                ),
                              )
                            : const CircleAvatar(
                                radius: 36.0,
                                backgroundImage: AssetImage(kUserAvatar),
                                backgroundColor: Colors.transparent,
                              ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${state.user.firstName} ${state.user.lastName}",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(state.user.email)
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRouter.signIn);
                    },
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 36.0,
                          backgroundImage: AssetImage(kUserAvatar),
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Login in your account",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Text("")
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLogged) {
                return Column(children: [
                  const SizedBox(height: 30),
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return OtherItemCard(
                        onClick: () {
                          if (state is UserLogged) {
                            Navigator.of(context).pushNamed(
                              AppRouter.userProfile,
                              arguments: state.user,
                            );
                          } else {
                            Navigator.of(context).pushNamed(AppRouter.signIn);
                          }
                        },
                        title: profileTitle,
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return OtherItemCard(
                        onClick: () {
                          if (state is UserLogged) {
                            Navigator.of(context).pushNamed(
                              AppRouter.myPublications,
                            );
                          } else {
                            Navigator.of(context).pushNamed(AppRouter.signIn);
                          }
                        },
                        title: publicationsTitle,
                      );
                    },
                  ),
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      if (state is UserLogged) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: OtherItemCard(
                            onClick: () {
                              Navigator.of(context)
                                  .pushNamed(AppRouter.deliveryDetails);
                            },
                            title: "Delivery Info",
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  // const SizedBox(height: 6),
                  // OtherItemCard(
                  //   onClick: () {
                  //     Navigator.of(context).pushNamed(AppRouter.settings);
                  //   },
                  //   title: "Settings",
                  // ),
                  // const SizedBox(height: 6),
                  // OtherItemCard(
                  //   onClick: () {
                  //     Navigator.of(context)
                  //         .pushNamed(AppRouter.notifications);
                  //   },
                  //   title: "Notifications",
                  // ),
                  // const SizedBox(height: 6),
                  // updateTypesenseFirestore(),
                ]);
              } else {
                return const SizedBox();
              }
            },
          ),
          const SizedBox(height: 6),
          OtherItemCard(
            onClick: () {
              Navigator.of(context).pushNamed(AppRouter.about);
            },
            title: "About",
          ),
          // const SizedBox(height: 6),
          // OtherItemCard(
          //   onClick: () {
          //     context.read<FavoritesBloc>().add(const ClearFavorites());
          //   },
          //   title: "--- Clear Favorites ---",
          // ),
          const SizedBox(height: 6),
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLogged) {
                return Column(children: [
                  OtherItemCard(
                    onClick: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SignOutConfirmationAlert(
                            onSignOut: () {
                              context.read<UserBloc>().add(SignOutUser());
                              context
                                  .read<FavoritesBloc>()
                                  .add(const ClearFavorites());
                            },
                          );
                        },
                      );
                    },
                    title: "Sign Out",
                  )
                ]);
              } else {
                return const SizedBox();
              }
            },
          ),
          SizedBox(height: (MediaQuery.of(context).padding.bottom + 50)),
        ],
      ),
    );
  }
}
