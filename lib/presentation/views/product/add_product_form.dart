import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/constant/collections.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/constant/strings.dart';
import 'package:spoto/data/models/category/category_model.dart';
import 'package:spoto/data/models/product/price_tag_model.dart';
import 'package:spoto/data/models/product/product_model.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/domain/entities/category/category.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/presentation/blocs/product/product_bloc.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/widgets/adaptive_alert_dialog.dart';
import 'package:spoto/presentation/widgets/input_dropdown_menu.dart';
import 'package:spoto/presentation/widgets/input_form_button.dart';
import 'package:spoto/presentation/widgets/input_image_upload.dart';
import 'package:spoto/presentation/widgets/input_text_form_field.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';

class AddProductForm extends StatefulWidget {
  // TODO: implement https://fluttergems.dev/packages/flutter_onboarding_slider/
  final Product? productInfo;

  const AddProductForm({
    super.key,
    this.productInfo,
  });

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  String? id;
  bool? isNew;
  bool isPublishPressed = false;
  int? initialLabelIndex;

  final TextEditingController name = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController priceTags = TextEditingController();
  List<String> images = [];
  Category? selectedCategory;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    final existingProduct = widget.productInfo;
    if (widget.productInfo != null) {
      id = widget.productInfo!.id;
      name.text = existingProduct?.name ?? "";
      description.text = existingProduct?.description ?? "";
      priceTags.text = existingProduct?.priceTags.first.price.toString() ?? "";
      images = existingProduct?.images ?? [];
      setState(() {
        isNew = existingProduct?.isNew;
        initialLabelIndex = isNew != null ? (isNew! ? 0 : 1) : null;
        selectedCategory = existingProduct?.categories.first;
      });
    }
    super.initState();
  }

  void _setIsPublishPressed() {
    setState(() {
      isPublishPressed = !isPublishPressed;
    });
  }

  void _handleImageUpload(List<String> imageURLs) {
    setState(() {
      images = imageURLs;
    });
  }

  void _handleCategorySelection(CategoryModel category) {
    setState(() {
      selectedCategory = category;
    });
  }

  Future<dynamic>? onClickClose() {
    if (name.text.isNotEmpty ||
        description.text.isNotEmpty ||
        isNew != null ||
        selectedCategory != null ||
        priceTags.text.isNotEmpty) {
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
    return Column(
      children: [
        ToggleSwitch(
          minWidth: 120,
          cornerRadius: 20.0,
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
              },
            );
          },
        ),
        if (isNew == null && isPublishPressed)
          const Text('Type selection is required',
              style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget titleField() {
    return InputTextFormField(
      controller: name,
      hint: 'Name',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      validation: (String? val) {
        if (val == null || val.isEmpty) {
          return fieldCantBeEmpty;
        }
        return null;
      },
    );
  }

  SizedBox formDivider() {
    return const SizedBox(
      height: 10,
    );
  }

  Widget descriptionField() {
    return InputTextFormField(
      controller: description,
      hint: 'Description',
      maxLines: 6,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      validation: (String? val) {
        if (val == null || val.isEmpty) {
          return fieldCantBeEmpty;
        }
        return null;
      },
    );
  }

  Widget priceField() {
    return InputTextFormField(
      controller: priceTags,
      hint: 'Price',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      validation: (String? val) {
        if (val == null || val.isEmpty) {
          return fieldCantBeEmpty;
        }
        return null;
      },
    );
  }

  Widget addProductButton() {
    return InputFormButton(
      color: Colors.black87,
      onClick: () async {
        _setIsPublishPressed();
        if (_formKey.currentState!.validate() && isNew != null) {
          final userId =
              (context.read<UserBloc>().state.props.first as UserModel).id;
          var uuid = const Uuid();
          final updatedModel = ProductModel(
              id: uuid.v1(),
              ownerId: userId,
              name: name.text,
              description: description.text,
              isNew: isNew!,
              status: ProductStatus.active,
              priceTags: [
                PriceTagModel(
                    id: '1', name: "base", price: int.parse(priceTags.text))
              ],
              categories: [CategoryModel.fromEntity(selectedCategory!)],
              category: selectedCategory!.name,
              images: images.isEmpty ? [] : images,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now());
          context.read<ProductBloc>().add(AddProduct(updatedModel));
          EasyLoading.showSuccess(productPublishedSuccessfully);
          Navigator.of(context).pop();
        }
      },
      titleText: 'Publish',
    );
  }

  Widget updateProductButton() {
    return InputFormButton(
      color: Colors.black87,
      onClick: () async {
        _setIsPublishPressed();
        if (_formKey.currentState!.validate() && isNew != null) {
          final updatedModel = ProductModel(
              id: widget.productInfo!.id,
              ownerId: widget.productInfo!.ownerId,
              name: name.text,
              description: description.text,
              isNew: isNew!,
              status: ProductStatus.active,
              priceTags: [
                PriceTagModel(
                    id: '1', name: "base", price: int.parse(priceTags.text))
              ],
              categories: [CategoryModel.fromEntity(selectedCategory!)],
              category: selectedCategory!.name,
              images: images.isEmpty ? [noImagePlaceholder] : images,
              createdAt: widget.productInfo!.createdAt,
              updatedAt: DateTime.now());
          context.read<ProductBloc>().add(UpdateProduct(updatedModel));
          EasyLoading.showSuccess(productUpdatedSuccessfully);
          Navigator.of(context).pop();
        }
      },
      titleText: 'Update',
    );
  }

  bool isExistingProductUpdated() {
    return name.text != widget.productInfo!.name ||
        description.text != widget.productInfo!.description ||
        isNew != widget.productInfo!.isNew ||
        images != widget.productInfo!.images ||
        selectedCategory != widget.productInfo!.categories.first ||
        priceTags.text != widget.productInfo!.priceTags.first.price.toString();
  }

  bool isProductInfoUpdated() {
    return name.text.isNotEmpty ||
        description.text.isNotEmpty ||
        isNew != null ||
        images.isNotEmpty ||
        selectedCategory != null ||
        priceTags.text.isNotEmpty;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              const SizedBox(
                height: 24,
              ),
              Center(
                child: Text(
                  widget.productInfo == null
                      ? addPublication
                      : updatePublication,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    ImageUploadForm(
                        onImagesUploaded: _handleImageUpload,
                        existingImages: images),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(children: [
                    formDivider(),
                    titleField(),
                    formDivider(),
                    descriptionField(),
                    formDivider(),
                    productTypeToggle(),
                    formDivider(),
                    priceField(),
                    formDivider(),
                    CategoriesDropdownMenu(
                      onCategorySelected: _handleCategorySelection,
                      existingCategory: selectedCategory,
                    ),
                    formDivider(),
                    // formDivider(),
                    widget.productInfo == null
                        ? addProductButton()
                        : updateProductButton(),
                    formDivider(),
                    // InputFormButton(
                    //   color: Colors.black26,
                    //   onClick: () {
                    //     context.read<NavbarCubit>().controller.animateToPage(0,
                    //         duration: const Duration(milliseconds: 400),
                    //         curve: Curves.linear);
                    //     context.read<NavbarCubit>().update(0);
                    //   },
                    //   titleText: 'Save draft',
                    // ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    InputFormButton(
                      color: Colors.black87,
                      onClick: () {
                        onPopupClose();
                      },
                      titleText: 'Cancel',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}
