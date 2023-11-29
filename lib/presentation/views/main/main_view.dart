import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:trudor/presentation/views/main/add/add_product.dart';
import 'package:trudor/presentation/widgets/popup_card/add_todo_button.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<NavbarCubit, int>(
            builder: (context, state) {
              return AnimatedContainer(
                duration: const Duration(seconds: 1),
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: context.read<NavbarCubit>().controller,
                  children: const <Widget>[
                    HomeView(),
                    CategoryView(),
                    AddProductForm(),
                    FavoritesView(),
                    OtherView(),
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
                    height: 90,
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
                      context.read<NavbarCubit>().controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.linear);
                      context.read<NavbarCubit>().update(index);
                    }),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined, size: 25),
                        activeIcon: Icon(Icons.home, size: 25),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.dashboard_outlined, size: 25),
                          activeIcon: Icon(Icons.dashboard, size: 25),
                          label: 'Category'),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_circle_outline_rounded, size: 0),
                        activeIcon: Icon(Icons.add_circle, size: 0),
                        // label: 'Publish'
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.favorite_border, size: 25),
                          activeIcon: Icon(Icons.favorite, size: 25),
                          label: 'Favorites'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.manage_accounts_outlined, size: 25),
                          activeIcon: Icon(Icons.manage_accounts, size: 25),
                          label: 'User'),
                    ],
                  );
                },
              ),
            ),
          ),
          const Positioned(
            bottom: 20.0,
            left: 105,
            right: 105,
            child: AddProductFloatingCard(),
          ),
        ],
      ),
    );
  }
}
