import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/presentation/widgets/adaptive_alert_dialog.dart';

import '../../../../core/constant/images.dart';
import '../../../../core/router/app_router.dart';
import '../../../blocs/favorites/favorites_bloc.dart';
import '../../../blocs/user/user_bloc.dart';
import '../../../widgets/other_item_card.dart';

class OtherView extends StatelessWidget {
  const OtherView({Key? key}) : super(key: key);

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
                            Navigator.of(context)
                                .pushNamed(AppRouter.signIn);
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
                              arguments: state.user,
                            );
                          } else {
                            Navigator.of(context)
                                .pushNamed(AppRouter.signIn);
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
                        builder: (context)
                      {
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
