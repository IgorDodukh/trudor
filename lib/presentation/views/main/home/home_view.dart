import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spoto/core/constant/messages.dart';

import '../../../../core/constant/images.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/usecases/product/get_product_usecase.dart';
import '../../../blocs/filter/filter_cubit.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../widgets/alert_card.dart';
import '../../../widgets/input_form_button.dart';
import '../../../widgets/product_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController scrollController = ScrollController();

  // TODO: check if this global variable works
  String searchValue = "";

  void _scrollListener() {
    double maxScroll = scrollController.position.maxScrollExtent;
    double currentScroll = scrollController.position.pixels;
    double scrollPercentage = 0.7;
    if (currentScroll > (maxScroll * scrollPercentage)) {
      if (context.read<ProductBloc>().state is ProductLoaded) {
        context.read<ProductBloc>().add(GetMoreProducts(context.read<FilterCubit>().state));
      }
    }
  }

  void _loadProducts([FilterProductParams? params]) {
    final filterParams = params ?? context.read<FilterCubit>().state;
    context.read<ProductBloc>().add(GetProducts(filterParams));
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: (MediaQuery.of(context).padding.top - 10),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 12,
              left: 20,
              right: 20,
            ),
            child: Row(
              children: [
                Expanded(
                  child: BlocBuilder<FilterCubit, FilterProductParams>(
                    builder: (context, state) {
                      return TextField(
                        autofocus: false,
                        controller:
                            context.read<FilterCubit>().searchController,
                        onChanged: (val) => setState(() {
                          searchValue = val;
                        }),
                        onSubmitted: (val) => {
                          setState(() {
                            searchValue = val;
                          }),
                          _loadProducts(),
                        },
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 20, bottom: 22, top: 22),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.search),
                            ),
                            suffixIcon: context
                                    .read<FilterCubit>()
                                    .searchController
                                    .text
                                    .isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: IconButton(
                                        onPressed: () {
                                          context
                                              .read<FilterCubit>()
                                              .searchController
                                              .clear();
                                          context
                                              .read<FilterCubit>()
                                              .update(keyword: '');
                                          _loadProducts(
                                              const FilterProductParams());
                                        },
                                        icon: const Icon(Icons.clear)),
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                            hintText: searchProductHint,
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 3.0),
                                borderRadius: BorderRadius.circular(26)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(26),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 3.0),
                            )),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 55,
                  child: BlocBuilder<FilterCubit, FilterProductParams>(
                    builder: (context, state) {
                      return Badge(
                        alignment: AlignmentDirectional.topEnd,
                        label: Text(
                          context
                              .read<FilterCubit>()
                              .getFiltersCount()
                              .toString(),
                          style: const TextStyle(color: Colors.black87),
                        ),
                        isLabelVisible:
                            context.read<FilterCubit>().getFiltersCount() != 0,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: InputFormButton(
                          color: Colors.black87,
                          onClick: () {
                            Navigator.of(context).pushNamed(AppRouter.filter);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                  //Result Empty and No Error
                  if (state is ProductLoaded && state.products.isEmpty) {
                    return const AlertCard(
                      image: kEmpty,
                      message: "Products not found!",
                    );
                  }
                  //Error and no preloaded data
                  if (state is ProductError && state.products.isEmpty) {
                    if (state.failure is NetworkFailure) {
                      return AlertCard(
                        image: kNoConnection,
                        message: "Network failure\nTry again!",
                        onClick: () {
                          _loadProducts(FilterProductParams(
                              keyword: context
                                  .read<FilterCubit>()
                                  .searchController
                                  .text,
                              searchField: "name"));
                        },
                      );
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.failure is ExceptionFailure)
                          Image.asset(
                              'assets/status_image/internal-server-error.png'),
                        if (state.failure is ServerFailure)
                          Image.asset(
                              'assets/status_image/internal-server-error.png'),
                        if (state.failure is CacheFailure)
                          Image.asset('assets/status_image/no-connection.png'),
                        const Text("Products not found!"),
                        IconButton(
                            onPressed: () {
                              _loadProducts(FilterProductParams(
                                  keyword: context
                                      .read<FilterCubit>()
                                      .searchController
                                      .text,
                                  searchField: "name"));
                            },
                            icon: const Icon(Icons.refresh)),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        )
                      ],
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadProducts();
                    },
                    child: GridView.builder(
                      itemCount: state.products.length +
                          ((state is ProductLoading) ? 10 : 0),
                      controller: scrollController,
                      padding: EdgeInsets.only(
                          top: 18,
                          left: 20,
                          right: 20,
                          bottom: (80 + MediaQuery.of(context).padding.bottom)),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 6,
                      ),
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        if (state.products.length > index) {
                          return ProductCard(
                            product: state.products[index],
                          );
                        }
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade100,
                          highlightColor: Colors.white,
                          child: const ProductCard(),
                        );
                      },
                    ),
                  );
                })),
          )
        ],
      ),
    );
  }
}
