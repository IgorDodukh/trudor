import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spoto/core/constant/collections.dart';
import 'package:spoto/core/constant/images.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/core/util/mappings.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/domain/usecases/product/get_product_usecase.dart';
import 'package:spoto/presentation/blocs/product/product_bloc.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/widgets/alert_card.dart';
import 'package:spoto/presentation/widgets/list_view_item_card.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MyPublicationsView extends StatefulWidget {
  const MyPublicationsView({Key? key}) : super(key: key);

  @override
  State<MyPublicationsView> createState() => _MyPublicationsViewState();
}

class _MyPublicationsViewState extends State<MyPublicationsView> {
  final ScrollController scrollController = ScrollController();
  String userId = "";
  int currentIndex = 0;

  void _scrollListener() {
    double maxScroll = scrollController.position.maxScrollExtent;
    double currentScroll = scrollController.position.pixels;
    double scrollPercentage = 0.7;
    if (currentScroll > (maxScroll * scrollPercentage)) {
      if (context.read<ProductBloc>().state is ProductLoaded) {
        context.read<ProductBloc>().add(const GetMoreProducts());
      }
    }
  }

  void getOwnedActiveProducts() {
    context.read<ProductBloc>().add(GetProducts(FilterProductParams(
        keyword: userId,
        searchField: "ownerId",
        status: ProductStatus.active.name.toString())));
  }

  void getOwnedInactiveProducts() {
    context.read<ProductBloc>().add(GetProducts(FilterProductParams(
        keyword: userId,
        searchField: "ownerId",
        status: ProductStatus.inactive.name.toString())));
  }

  @override
  void initState() {
    setState(() {
      userId = (context.read<UserBloc>().state.props.first as UserModel).id;
    });
    getOwnedActiveProducts();
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(publicationsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            Column(
              children: [
                ToggleSwitch(
                  minWidth: MediaQuery.of(context).size.width * 0.43,
                  cornerRadius: 20.0,
                  activeBgColor: const [Colors.black87],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.black12,
                  initialLabelIndex: 0,
                  totalSwitches: 2,
                  labels: ProductStatus.values
                      .map((e) =>
                          StringUtils.capitalize(e.toString().split('.').last))
                      .toList(),
                  radiusStyle: true,
                  onToggle: (index) {
                    currentIndex = index!;
                    if (currentIndex == 0) {
                      getOwnedActiveProducts();
                    } else {
                      getOwnedInactiveProducts();
                    }
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BlocListener<ProductBloc, ProductState>(
                      listener: (context, state) {
                        if (state is ProductError) {
                          print(
                              "state is ProductError in My Publications View");
                        }
                      },
                      child: BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          if (state is ProductLoaded &&
                              state.products.isEmpty) {
                            return const AlertCard(
                              image: kEmpty,
                              message: "No publications found!",
                            );
                          }
                          if (state is ProductError && state.products.isEmpty) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (state.failure is NetworkFailure)
                                  Image.asset(kNoConnection),
                                if (state.failure is ServerFailure)
                                  Image.asset(kInternalServerError),
                                if (state.failure is ExceptionFailure)
                                  Image.asset(kInternalServerError),
                                Text(state.failure.toString()),
                                const Text("No publications found"),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                )
                              ],
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () async {
                              if (currentIndex == 0) {
                                getOwnedActiveProducts();
                              } else {
                                getOwnedInactiveProducts();
                              }
                            },
                            child: ListView.builder(
                              itemCount: state.products.length +
                                  ((state is ProductLoading) ? 10 : 0),
                              controller: scrollController,
                              padding: EdgeInsets.only(
                                  top:
                                      (MediaQuery.of(context).padding.top + 20),
                                  bottom:
                                      MediaQuery.of(context).padding.bottom +
                                          200),
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                if (state.products.length > index) {
                                  return ListViewItemCard(
                                      listViewItem:
                                          ProductMapping.productToListViewItem(
                                              state.products[index]),
                                      isOwned: true);
                                }
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade100,
                                  highlightColor: Colors.white,
                                  child: const ListViewItemCard(isOwned: true),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
