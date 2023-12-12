import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/presentation/blocs/product/product_bloc.dart';
import 'package:spoto/presentation/widgets/input_text_form_field.dart';

import '../../../../../domain/usecases/product/get_product_usecase.dart';
import '../../../../blocs/category/category_bloc.dart';
import '../../../../blocs/filter/filter_cubit.dart';
import '../../../../widgets/input_form_button.dart';

class FilterView extends StatefulWidget {
  const FilterView({Key? key}) : super(key: key);

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  String priceRangeValidation = '';

  void setPriceRange() {
    minPriceController.text =
        context.read<FilterCubit>().state.minPrice?.toString() ?? '';
    maxPriceController.text =
        context.read<FilterCubit>().state.maxPrice?.toString() ?? '';
    if (minPriceController.text.endsWith(".0")) {
      minPriceController.text = minPriceController.text.replaceAll(".0", "");
    }
    if (maxPriceController.text.endsWith(".0")) {
      maxPriceController.text = maxPriceController.text.replaceAll(".0", "");
    }
  }

  void validatePriceRange() {
    if (minPriceController.text.isNotEmpty &&
        maxPriceController.text.isNotEmpty) {
      if (double.parse(minPriceController.text.replaceAll(",", ".")) >
          double.parse(maxPriceController.text.replaceAll(",", "."))) {
        setState(() {
          priceRangeValidation = priceRangeValidationMessage;
        });
      } else {
        setState(() {
          priceRangeValidation = "";
        });
      }
    } else {
      setState(() {
        priceRangeValidation = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setPriceRange();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(filterTitle),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          TextButton(
              onPressed: () {
                context.read<FilterCubit>().reset();
                setPriceRange();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                textStyle:
                    const TextStyle(decoration: TextDecoration.underline),
              ),
              child: const Text(resetAllTitle)),
        ],
      ),
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  top: 10,
                ),
                child: Text(
                  categoriesTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoryState) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryState.categories.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemBuilder: (context, index) => Row(
                      children: [
                        Text(
                          categoryState.categories[index].name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        BlocBuilder<FilterCubit, FilterProductParams>(
                          builder: (context, filterState) {
                            return Checkbox(
                              value: filterState.categories.contains(
                                      categoryState.categories[index]) ||
                                  filterState.categories.isEmpty,
                              onChanged: (bool? value) {
                                context.read<FilterCubit>().updateCategory(
                                    category: categoryState.categories[index]);
                              },
                            );
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 10),
                child: Row(
                  children: [
                    Text(
                      priceRangeTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // build two fields for min and max price
              const SizedBox(height: 12),
              BlocBuilder<FilterCubit, FilterProductParams>(
                builder: (context, state) {
                  return Row(children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: InputTextFormField(
                        controller: minPriceController,
                        hint: minPriceHint,
                        maxCharacters: 13,
                        textInputType: const TextInputType.numberWithOptions(
                            decimal: true),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        onChanged: (value) {
                          if (value != null && value.startsWith(",")) {
                            minPriceController.text = "0.";
                          } else if (value != null && value.contains(",")) {
                            minPriceController.text =
                                minPriceController.text.replaceAll(",", ".");
                          }
                          validatePriceRange();
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text("-"),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InputTextFormField(
                        controller: maxPriceController,
                        hint: maxPriceHint,
                        maxCharacters: 13,
                        textInputType: const TextInputType.numberWithOptions(
                            decimal: true),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        onChanged: (value) {
                          if (value != null && value.startsWith(",")) {
                            maxPriceController.text = "0.";
                          } else if (value != null && value.contains(",")) {
                            maxPriceController.text =
                                maxPriceController.text.replaceAll(",", ".");
                          }
                          validatePriceRange();
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                  ]);
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  priceRangeValidation,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          )),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Builder(builder: (context) {
            return InputFormButton(
              color: Colors.black87,
              onClick: () {
                if (priceRangeValidation.isNotEmpty) {
                  return;
                }
                double? minPrice = minPriceController.text.isEmpty
                    ? null
                    : double.parse(
                        minPriceController.text.replaceAll(",", "."));
                double? maxPrice = maxPriceController.text.isEmpty
                    ? null
                    : double.parse(
                        maxPriceController.text.replaceAll(",", "."));
                context
                    .read<FilterCubit>()
                    .update(minPrice: minPrice, maxPrice: maxPrice);
                context
                    .read<ProductBloc>()
                    .add(GetProducts(context.read<FilterCubit>().state));
                Navigator.of(context).pop();
              },
              titleText: applyFiltersTitle,
            );
          }),
        ),
      ),
    );
  }
}
