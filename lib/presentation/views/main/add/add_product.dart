import 'package:trudor/core/router/app_router.dart';
import 'package:trudor/core/util/firstore_folder_methods.dart';
import 'package:trudor/data/models/category/category_model.dart';
import 'package:trudor/data/models/product/price_tag_model.dart';
import 'package:trudor/data/models/product/product_model.dart';
import 'package:trudor/domain/entities/category/category.dart';
import 'package:trudor/domain/entities/product/product.dart';
import 'package:trudor/presentation/blocs/home/navbar_cubit.dart';
import 'package:trudor/presentation/widgets/input_dropdown_menu.dart';
import 'package:trudor/presentation/widgets/input_form_button.dart';
import 'package:trudor/presentation/widgets/input_image_upload.dart';
import 'package:trudor/presentation/widgets/input_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';


class AddProductForm extends StatefulWidget {
  // TODO: change add product form to floating card
  // https://www.youtube.com/watch?v=Bxs8Zy2O4wk&t=7s
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
  final TextEditingController name = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController priceTags = TextEditingController();
  List<String>? images;
  Category? selectedCategory;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.productInfo != null) {
      id = widget.productInfo!.id;

      name.text = widget.productInfo!.name;
      description.text = widget.productInfo!.description;
      priceTags.text = widget.productInfo!.priceTags.first.toString();
      selectedCategory = widget.productInfo!.categories.first;
      images = [];
    }
    super.initState();
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

  void cleanUp() {
    name.text = "";
    description.text = "";
    priceTags.text = "";
    selectedCategory = null;
    images = [];
  }

  @override
  Widget build(BuildContext context) {
    return
      SizedBox(
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                      controller: priceTags,
                      hint: 'Price',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                    CategoriesDropdownMenu(onCategorySelected: _handleCategorySelection),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    InputFormButton(
                      color: Colors.black87,
                      onClick: () async {
                        if (_formKey.currentState!.validate()) {
                          var uuid = const Uuid();
                          FirestoreService firestoreService = FirestoreService();
                          await firestoreService.createProduct(
                              ProductModel(
                                  id: uuid.v1(),
                                  name: name.text,
                                  description: description.text,
                                  priceTags: [PriceTagModel(
                                      id: '1', name: "base", price: int.parse(priceTags.text))
                                  ],
                                  categories: [CategoryModel.fromEntity(selectedCategory!)],
                                  images: images!,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now()));
                          cleanUp();
                          context.read<NavbarCubit>().controller.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.linear);
                          context.read<NavbarCubit>().update(0);
                        }
                      },
                      titleText: widget.productInfo == null ? 'Publish' : 'Update',
                    ),
                    const SizedBox(
                      height: 90,
                    ),

                  ])
                ),
                  // InputFormButton(
                  //   color: Colors.black87,
                  //   onClick: () {
                  //     Navigator.of(context).pushNamed(AppRouter.home);
                  //   },
                  //   titleText: 'Cancel',
                  // ),
                ],
              ),
            ),
          // ),
        ),
      // ),
    );
  }
}
