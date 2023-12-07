import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:trudor/core/constant/collections.dart';
import 'package:trudor/core/constant/messages.dart';
import 'package:trudor/core/util/firstore_folder_methods.dart';
import 'package:trudor/data/models/category/category_model.dart';
import 'package:trudor/data/models/product/price_tag_model.dart';
import 'package:trudor/data/models/product/product_model.dart';
import 'package:trudor/data/models/user/user_model.dart';
import 'package:trudor/domain/entities/category/category.dart';
import 'package:trudor/domain/entities/product/product.dart';
import 'package:trudor/presentation/blocs/home/navbar_cubit.dart';
import 'package:trudor/presentation/blocs/user/user_bloc.dart';
import 'package:trudor/presentation/widgets/adaptive_alert_dialog.dart';
import 'package:trudor/presentation/widgets/input_dropdown_menu.dart';
import 'package:trudor/presentation/widgets/input_form_button.dart';
import 'package:trudor/presentation/widgets/input_image_upload.dart';
import 'package:trudor/presentation/widgets/input_text_form_field.dart';
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
    if (widget.productInfo != null) {
      id = widget.productInfo!.id;
      name.text = widget.productInfo!.name;
      isNew = widget.productInfo!.isNew!;
      description.text = widget.productInfo!.description;
      priceTags.text = widget.productInfo!.priceTags.first.toString();
      selectedCategory = widget.productInfo!.categories.first;
      images = [];
      initialLabelIndex = null;
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

  void cleanUp() {
    name.text = "";
    description.text = "";
    priceTags.text = "";
    setState(() {
      images = [];
      initialLabelIndex = null;
      selectedCategory = null;
      isNew = null;
      isPublishPressed = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    ImageUploadForm(onImagesUploaded: _handleImageUpload),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(children: [
                    const SizedBox(
                      height: 24,
                    ),
                    InputTextFormField(
                      controller: name,
                      hint: 'Name',
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      validation: (String? val) {
                        if (val == null || val.isEmpty) {
                          return 'This field can\'t be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputTextFormField(
                      controller: description,
                      hint: 'Description',
                      maxLines: 6,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      validation: (String? val) {
                        if (val == null || val.isEmpty) {
                          return 'This field can\'t be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    productTypeToggle(),
                    const SizedBox(
                      height: 10,
                    ),
                    InputTextFormField(
                      controller: priceTags,
                      hint: 'Price',
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      validation: (String? val) {
                        if (val == null || val.isEmpty) {
                          return 'This field can\'t be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CategoriesDropdownMenu(
                        onCategorySelected: _handleCategorySelection),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    InputFormButton(
                      color: Colors.black87,
                      onClick: () async {
                        _setIsPublishPressed();
                        if (_formKey.currentState!.validate() &&
                            isNew != null) {
                          final userId = (context
                                  .read<UserBloc>()
                                  .state
                                  .props
                                  .first as UserModel)
                              .id;
                          var uuid = const Uuid();
                          FirestoreService firestoreService =
                              FirestoreService();
                          await firestoreService.createProduct(ProductModel(
                              id: uuid.v1(),
                              ownerId: userId,
                              name: name.text,
                              description: description.text,
                              isNew: isNew!,
                              status: ProductStatus.active,
                              priceTags: [
                                PriceTagModel(
                                    id: '1',
                                    name: "base",
                                    price: int.parse(priceTags.text))
                              ],
                              categories: [
                                CategoryModel.fromEntity(selectedCategory!)
                              ],
                              category: selectedCategory!.name,
                              images: images.isEmpty
                                  ? []
                                  : images,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now()));
                          cleanUp();
                          EasyLoading.showSuccess(productPublishedSuccessfully);
                          context.read<NavbarCubit>().controller.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.linear);
                          context.read<NavbarCubit>().update(0);
                        }
                      },
                      titleText:
                          widget.productInfo == null ? 'Publish' : 'Update',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputFormButton(
                      color: Colors.black26,
                      onClick: () {
                        context.read<NavbarCubit>().controller.animateToPage(0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.linear);
                        context.read<NavbarCubit>().update(0);
                      },
                      titleText: 'Save draft',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputFormButton(
                      color: Colors.black26,
                      onClick: () {
                        cleanUp();
                      },
                      titleText: 'Cancel',
                    ),
                    const SizedBox(
                      height: 90,
                    ),
                  ])),
            ],
          ),
        ),
        // ),
      ),
    );
  }
}
