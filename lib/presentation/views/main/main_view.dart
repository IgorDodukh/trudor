import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:spoto/core/constant/colors.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/router/app_router.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/views/product/add_product_multistep.dart';
import 'package:spoto/presentation/views/product/add_product_pages/add_product_form.dart';
import 'package:spoto/presentation/widgets/adaptive_alert_dialog.dart';

import '../../blocs/home/navbar_cubit.dart';
import 'category/category_view.dart';
import 'favorites/favorites_view.dart';
import 'home/home_view.dart';
import 'other/other_view.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final double iconSize = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          BlocBuilder<NavbarCubit, int>(
            builder: (context, state) {
              return AnimatedContainer(
                duration: const Duration(seconds: 1),
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: context.read<NavbarCubit>().controller,
                  children: <Widget>[
                    const HomeView(),
                    CategoryView(),
                    const AddProductForm(),
                    const FavoritesView(),
                    const OtherView(),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: -34,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: BlocBuilder<NavbarCubit, int>(
                builder: (context, state) {
                  return SnakeNavigationBar.color(
                    behaviour: SnakeBarBehaviour.floating,
                    snakeShape: SnakeShape.indicator,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    backgroundColor: Colors.black87,
                    snakeViewColor: Colors.black87,
                    height: 70,
                    elevation: 6,
                    selectedItemColor: SnakeShape.circle == SnakeShape.indicator
                        ? Colors.black87
                        : null,
                    unselectedItemColor: Colors.white,
                    selectedLabelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    showUnselectedLabels: true,
                    showSelectedLabels: true,
                    currentIndex: state,
                    onTap: (index) => setState(() {
                      if (index == 4) {
                        final currentState = context.read<UserBloc>().state;
                        if (currentState is UserLoggedFail || currentState is UserLoggedOut) {
                          Navigator.of(context).pushNamed(AppRouter.signIn);
                          return;
                        }
                      }
                      context.read<NavbarCubit>().controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.linear);
                      context.read<NavbarCubit>().update(index);
                      if (index == 3) {
                        Future.delayed(
                            const Duration(milliseconds: 600),
                            () => {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const SignInToUseFeatureAlert(
                                          contentText:
                                              favoritesPageUnavailable);
                                    },
                                  )
                                });
                      }
                    }),
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined, size: iconSize),
                        activeIcon: Icon(Icons.home, size: iconSize),
                        // label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_outlined, size: iconSize),
                        activeIcon: Icon(Icons.dashboard, size: iconSize),
                        // label: 'Category'
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.add_circle_outline_rounded, size: 0),
                        activeIcon: Icon(Icons.add_circle, size: 0),
                        // label: 'Publish'
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite_border, size: iconSize),
                        activeIcon: Icon(Icons.favorite, size: iconSize),
                        // label: 'Favorites'
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.manage_accounts_outlined,
                            size: iconSize),
                        activeIcon: Icon(Icons.manage_accounts, size: iconSize),
                        // label: 'User'
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: -50.0,
            top: MediaQuery.of(context).size.height - 175,
            left: MediaQuery.of(context).size.width / 2 - 50,
            right: MediaQuery.of(context).size.width / 2 - 50,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  elevation: 0,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightElevation: 0,
                  foregroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  focusElevation: 0,
                  hoverElevation: 0,
                  onPressed: () async {
                    final currentState = context.read<UserBloc>().state;
                    if (currentState is UserLoggedFail || currentState is UserLoggedOut) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const SignInToUseFeatureAlert(
                              contentText: addProductPageUnavailable);
                        },
                      );
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AddProductMultiStepForm()),
                      );
                    }
                  },
                  child: Icon(
                    Icons.add_circle,
                    size: 65,
                    color: kButtonAccentColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
