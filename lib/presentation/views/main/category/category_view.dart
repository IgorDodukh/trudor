import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spoto/presentation/widgets/category_item.dart';

import '../../../blocs/category/category_bloc.dart';

class CategoryView extends StatefulWidget {
  final ValueChanged<String>? onCategorySelected;

  const CategoryView({Key? key, this.onCategorySelected}) : super(key: key);

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                padding: const EdgeInsets.only(top: 20),
                onPressed: () => {
                  Navigator.of(context).pop(),
                },
                icon: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.black54,
                  size: 35,
                ),
              ),
            ),
            const Text("Category",
                style: TextStyle(
                    fontSize: 30,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black)), // Text("Categories"),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  return ListView.builder(
                    itemCount: state.categories.length,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                        top: 14,
                        bottom: (80 + MediaQuery.of(context).padding.bottom)),
                    itemBuilder: (context, index) => (state is CategoryLoading)
                        ? CategoryItemCard()
                        : CategoryItemCard(
                            onCategorySelected: widget.onCategorySelected,
                            category: state.categories[index],
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
