import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spoto/core/constant/collections.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/util/price_handler.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/presentation/blocs/home/navbar_cubit.dart';
import 'package:spoto/presentation/views/main/category/category_view.dart';
import 'package:spoto/presentation/widgets/input_form_button.dart';
import 'package:spoto/presentation/widgets/input_text_form_field.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AddProductForm extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final Product? productInfo;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onDescriptionChanged;
  final ValueChanged<bool>? onTypeChanged;
  final ValueChanged<String>? onPriceChanged;
  final ValueChanged<String>? onCategoryChanged;

  const AddProductForm({
    super.key,
    this.formKey,
    this.productInfo,
    this.onNameChanged,
    this.onDescriptionChanged,
    this.onTypeChanged,
    this.onPriceChanged,
    this.onCategoryChanged,
  });

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  String? id;
  bool? isNew;
  int? initialLabelIndex;
  bool isFree = false;
  bool isPriceValid = true;
  double formDividerHeight = 20;
  bool isCategoryValid = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String? selectedCategory;

  @override
  void initState() {
    final existingProduct = widget.productInfo;
    if (widget.productInfo != null) {
      final existingPriceVal =
          NumberHandler.formatPrice(existingProduct!.price);
      id = widget.productInfo!.id;
      nameController.text = existingProduct.name;
      descriptionController.text = existingProduct.description;
      priceController.text =
          existingPriceVal == "0" ? itsFreeHint : existingPriceVal;
      setState(() {
        isNew = existingProduct.isNew;
        initialLabelIndex = isNew != null ? (isNew! ? 0 : 1) : null;
        selectedCategory = existingProduct.category;
        isFree = existingProduct.price == 0;
      });
    }
    super.initState();
  }

  void _handleCategorySelection(String category) {
    setState(() {
      selectedCategory = category;
      widget.onCategoryChanged!(category);
      if (selectedCategory == null) {
        isCategoryValid = false;
      } else {
        isCategoryValid = true;
      }
    });
  }

  Widget productTypeToggle() {
    return FormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (val) {
        if (isNew == null) return typeValidation;
        return null;
      },
      builder: (FormFieldState<bool> field) {
        return InputDecorator(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0),
            errorText: field.errorText,
            border: InputBorder.none,
          ),
          child: ToggleSwitch(
            fontSize: 16,
            minWidth: MediaQuery.of(context).size.width * 0.43,
            cornerRadius: 14.0,
            activeBgColor: const [Colors.black87],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.black12,
            initialLabelIndex: initialLabelIndex,
            totalSwitches: 2,
            labels: productType,
            radiusStyle: true,
            onToggle: (index) {
              setState(
                () {
                  initialLabelIndex = index!;
                  isNew = (index == 0);
                  widget.onTypeChanged!(isNew!);
                  field.didChange(isNew);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget titleField() {
    return InputTextFormField(
      controller: nameController,
      hint: nameHint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      validation: (String? val) {
        if (val == null || val.isEmpty) {
          return nameValidation;
        }
        return null;
      },
      onChanged: (_) {
        setState(() {
          widget.onNameChanged!(nameController.text);
        });
        return null;
      },
    );
  }

  Widget descriptionField() {
    return InputTextFormField(
      controller: descriptionController,
      hint: descriptionHint,
      maxLines: 5,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      validation: (String? val) {
        if (val == null || val.isEmpty) {
          return descriptionValidation;
        }
        return null;
      },
      onChanged: (_) {
        setState(() {
          widget.onDescriptionChanged!(descriptionController.text);
        });
        return null;
      },
    );
  }

  Widget priceField() {
    return FormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (_) {
          if (priceController.text.isEmpty && !isFree) {
            return priceValidationText;
          }
          return null;
        },
        builder: (FormFieldState<bool> field) {
          return InputDecorator(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0),
                errorText: field.errorText,
                border: InputBorder.none,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: InputTextFormField(
                          enable: !isFree,
                          controller: priceController,
                          hint: isFree ? itsFreeHint : priceHint,
                          maxCharacters: 13,
                          textInputType: const TextInputType.numberWithOptions(
                              decimal: true),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          onChanged: (value) {
                            if (value != null && value.startsWith(",")) {
                              priceController.text = "0.";
                            } else if (value != null && value.contains(",")) {
                              priceController.text =
                                  priceController.text.replaceAll(",", ".");
                            }
                            if (value == null || value.isEmpty) {
                              setState(() {
                                isPriceValid = false;
                              });
                            } else {
                              setState(() {
                                isPriceValid = true;
                              });
                            }
                            setState(() {
                              widget.onPriceChanged!(priceController.text);
                            });
                            field.didChange(isPriceValid);
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Row(
                        children: [
                          const Text(
                            freeSwitchTitle,
                            style: TextStyle(fontSize: 16),
                          ),
                          Switch.adaptive(
                            activeColor: Colors.black87,
                            value: isFree,
                            onChanged: (bool value) {
                              setState(() {
                                isFree = value;
                                priceController.text = "";
                                widget.onPriceChanged!(
                                    isFree ? "0" : priceController.text);
                              });
                              field.didChange(isPriceValid);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ));
        });
  }

  Widget saveDraftButton() {
    return InputFormButton(
      color: Colors.black26,
      onClick: () {
        context.read<NavbarCubit>().controller.animateToPage(0,
            duration: const Duration(milliseconds: 400), curve: Curves.linear);
        context.read<NavbarCubit>().update(0);
      },
      titleText: saveDraftTitle,
    );
  }

  Widget categoryPicker() {
    return FormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (_) {
          if (!isCategoryValid) {
            return categoryValidation;
          }
          return null;
        },
        builder: (FormFieldState<bool> field) {
          return InputDecorator(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0),
                errorText: field.errorText,
                border: InputBorder.none,
              ),
              child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      enableDrag: false,
                      isDismissible: false,
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      builder: (BuildContext context) {
                        return CategoryView(
                            onCategorySelected: _handleCategorySelection);
                      },
                    );
                    field.didChange(isCategoryValid);
                  },
                  child: Stack(
                    children: [
                      Card(
                        color: selectedCategory != null
                            ? Colors.black54
                            : Colors.grey.shade100,
                        margin: const EdgeInsets.all(0),
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: SizedBox(
                          height: 45,
                          width: double.maxFinite,
                          child: Hero(
                            tag: "Select category",
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedCategory != null
                                    ? Colors.black54
                                    : Colors.black12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          left: 15,
                          bottom: 15,
                          child: Container(
                            // padding: const EdgeInsets.symmetric(
                            //     vertical: 0, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedCategory ?? selectCategoryTitle,
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedCategory != null
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          )),
                      Positioned(
                          right: 15,
                          bottom: 12,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: selectedCategory != null
                                ? Colors.white
                                : Colors.black87,
                          )),
                    ],
                  )));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        SizedBox(
          child: Form(
            key: widget.formKey,
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(children: [
                      titleField(),
                      SizedBox(height: formDividerHeight),
                      descriptionField(),
                      SizedBox(height: formDividerHeight),
                      productTypeToggle(),
                      SizedBox(height: formDividerHeight),
                      priceField(),
                      SizedBox(height: formDividerHeight),
                      categoryPicker(),
                    ])),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
