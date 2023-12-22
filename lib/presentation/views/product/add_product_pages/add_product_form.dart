import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/constant/collections.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/util/price_handler.dart';
import 'package:spoto/data/models/product/price_tag_model.dart';
import 'package:spoto/data/models/product/product_model.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/presentation/blocs/home/navbar_cubit.dart';
import 'package:spoto/presentation/blocs/product/product_bloc.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/views/main/category/category_view.dart';
import 'package:spoto/presentation/widgets/adaptive_alert_dialog.dart';
import 'package:spoto/presentation/widgets/input_form_button.dart';
import 'package:spoto/presentation/widgets/input_text_form_field.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';

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
  bool isPublishPressed = false;
  int? initialLabelIndex;
  bool isFree = false;
  bool isPriceValid = true;
  double formDividerHeight = 20;
  bool isCategoryValid = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<String> images = [];
  String? selectedCategory;

  @override
  void initState() {
    final existingProduct = widget.productInfo;
    if (widget.productInfo != null) {
      id = widget.productInfo!.id;
      nameController.text = existingProduct?.name ?? "";
      descriptionController.text = existingProduct?.description ?? "";
      setState(() {
        isNew = existingProduct?.isNew;
        initialLabelIndex = isNew != null ? (isNew! ? 0 : 1) : null;
        selectedCategory = existingProduct?.category;
      });
      priceController.text =
          NumberHandler.formatPrice(existingProduct!.priceTags.first.price);
    }
    super.initState();
  }

  void _setIsPublishPressed() {
    setState(() {
      isPublishPressed = !isPublishPressed;
    });
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

  Future<dynamic>? onClickClose() {
    if (nameController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        isNew != null ||
        selectedCategory != null ||
        priceController.text.isNotEmpty) {
      return showDialog(
        context: context,
        builder: (context) {
          return const DiscardChangesAlert();
        },
      );
    }
    Navigator.of(context).pop();
    return Future(() => null);
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

  SizedBox formDivider() {
    return const SizedBox(
      height: 20,
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

  Widget addProductButton() {
    return InputFormButton(
      color: Colors.black87,
      onClick: () async {
        _setIsPublishPressed();
        if (widget.formKey!.currentState!.validate() && isNew != null) {
          final userId =
              (context.read<UserBloc>().state.props.first as UserModel).id;
          var uuid = const Uuid();
          final updatedModel = ProductModel(
              id: uuid.v1(),
              ownerId: userId,
              name: nameController.text,
              description: descriptionController.text,
              isNew: isNew!,
              status: ProductStatus.active,
              price: double.parse(priceController.text.replaceAll(",", ".")),
              priceTags: [
                PriceTagModel(
                    id: '1',
                    name: "base",
                    price:
                        double.parse(priceController.text.replaceAll(",", ".")))
              ],
              // categories: [CategoryModel.fromEntity(selectedCategory!)],
              category: selectedCategory!,
              images: images.isEmpty ? [] : images,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now());
          context.read<ProductBloc>().add(AddProduct(updatedModel));
          EasyLoading.showSuccess(productPublishedSuccessfully);
          Navigator.of(context).pop();
        }
      },
      titleText: publishTitle,
    );
  }

  Widget updateProductButton() {
    return InputFormButton(
      color: Colors.black87,
      onClick: () async {
        _setIsPublishPressed();
        if (widget.formKey!.currentState!.validate() && isNew != null) {
          final updatedModel = ProductModel(
              id: widget.productInfo!.id,
              ownerId: widget.productInfo!.ownerId,
              name: nameController.text,
              description: descriptionController.text,
              isNew: isNew!,
              status: ProductStatus.active,
              price: double.parse(priceController.text.replaceAll(",", ".")),
              priceTags: [
                PriceTagModel(
                    id: '1',
                    name: "base",
                    price:
                        double.parse(priceController.text.replaceAll(",", ".")))
              ],
              // categories: [CategoryModel.fromEntity(selectedCategory!)],
              category: selectedCategory!,
              images: images.isEmpty ? [] : images,
              createdAt: widget.productInfo!.createdAt,
              updatedAt: DateTime.now());
          context.read<ProductBloc>().add(UpdateProduct(updatedModel));
          EasyLoading.showSuccess(productUpdatedSuccessfully);
          Navigator.of(context).pop();
        }
      },
      titleText: updateTitle,
    );
  }

  bool isExistingProductUpdated() {
    return nameController.text != widget.productInfo!.name ||
        descriptionController.text != widget.productInfo!.description ||
        isNew != widget.productInfo!.isNew ||
        images != widget.productInfo!.images ||
        selectedCategory != widget.productInfo!.category ||
        priceController.text !=
            widget.productInfo!.priceTags.first.price.toString();
  }

  bool isProductInfoUpdated() {
    return nameController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        isNew != null ||
        images.isNotEmpty ||
        selectedCategory != null ||
        priceController.text.isNotEmpty;
  }

  Future<dynamic>? onPopupClose() {
    if (widget.productInfo != null) {
      if (isExistingProductUpdated()) {
        return showDialog(
          context: context,
          builder: (context) {
            return const DiscardChangesAlert();
          },
        );
      }
    } else if (isProductInfoUpdated()) {
      return showDialog(
        context: context,
        builder: (context) {
          return const DiscardChangesAlert();
        },
      );
    }
    Navigator.of(context).pop();
    return Future(() => null);
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

  Widget cancelButton() {
    return InputFormButton(
      color: Colors.white,
      textColor: Colors.black,
      onClick: () {
        onPopupClose();
      },
      titleText: cancelTitle,
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
