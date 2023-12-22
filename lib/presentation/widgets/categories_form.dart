import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spoto/presentation/blocs/category/category_bloc.dart';
import 'package:spoto/presentation/widgets/category_item.dart';

class SelectCategoryForm extends StatefulWidget {
  const SelectCategoryForm({
    super.key,
  });

  @override
  State<SelectCategoryForm> createState() => _SelectCategoryFormState();
}

class _SelectCategoryFormState extends State<SelectCategoryForm> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      return ListView.builder(
                        itemCount: state.categories.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) =>
                            (state is CategoryLoading)
                                ? CategoryItemCard()
                                : CategoryItemCard(
                                    category: state.categories[index],
                                  ),
                      );
                    },
                  ),
                ),
              ],
            )));
  }
}
