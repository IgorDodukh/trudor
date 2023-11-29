import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:trudor/core/constant/collections.dart';
import 'package:trudor/core/constant/strings.dart';
import 'package:trudor/core/util/firstore_folder_methods.dart';
import 'package:trudor/data/models/category/category_model.dart';
import 'package:trudor/data/models/product/price_tag_model.dart';
import 'package:trudor/data/models/product/product_model.dart';
import 'package:trudor/data/models/user/user_model.dart';
import 'package:trudor/domain/entities/category/category.dart';
import 'package:trudor/presentation/blocs/user/user_bloc.dart';
import 'package:trudor/presentation/widgets/adaptive_alert_dialog.dart';
import 'package:trudor/presentation/widgets/input_dropdown_menu.dart';
import 'package:trudor/presentation/widgets/input_image_upload.dart';
import 'package:trudor/presentation/widgets/input_text_form_field.dart';
import 'package:trudor/presentation/widgets/popup_card/styles.dart';
import 'package:uuid/uuid.dart';

import 'custom_rect_tween.dart';
import 'hero_dialog_route.dart';

/// {@template add_todo_button}
/// Button to add a new [Todo].
///
/// Opens a [HeroDialogRoute] of [PopupCard].
///
/// Uses a [Hero] with tag [_heroAddTodo].
/// {@endtemplate}
class AddProductFloatingCard extends StatelessWidget {
  /// {@macro add_todo_button}
  const AddProductFloatingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return const PopupCard();
          }));
        },
        child: Hero(
          tag: _heroAddTodo,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: const Icon(
            Icons.add_circle,
            size: 86,
            color: AppColors.buttonAccentColor,
          ),
        ),
      ),
    );
  }
}

/// Tag-value used for the add todo popup button.
const String _heroAddTodo = 'add-todo-hero';

/// {@template add_todo_popup_card}
/// Popup card to add a new [Todo]. Should be used in conjuction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroAddTodo].
/// {@endtemplate}
class PopupCard extends StatefulWidget {
  const PopupCard({Key? key}) : super(key: key);

  @override
  _PopupCardState createState() => _PopupCardState();
}

class _PopupCardState extends State<PopupCard> {
  /// {@macro add_todo_popup_card}
  bool? isNew;
  bool isPublishPressed = false;
  int? initialLabelIndex;
  Category? selectedCategory;

  // Product? productInfo;
  String? id;
  List<String> images = [];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController priceTags = TextEditingController();

  late final Future<void> myFuture;

  @override
  void initState() {
    super.initState();
    myFuture = Future.delayed(const Duration(milliseconds: 550));
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    priceTags.dispose();
    super.dispose();
  }

  void _setIsPublishPressed() {
    setState(() {
      isPublishPressed = !isPublishPressed;
    });
  }

  void _handleCategorySelection(CategoryModel category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void _handleImageUpload(List<String> imageURLs) {
    setState(() {
      images = imageURLs;
    });
  }

  Future<dynamic>? onPopupClose() {
    if (title.text.isNotEmpty ||
        description.text.isNotEmpty ||
        isNew != null ||
        images.isNotEmpty ||
        selectedCategory != null ||
        priceTags.text.isNotEmpty) {
      return showDialog(
        context: context,
        builder: (context) {
          return const AdaptiveDialog();
        },
      );
    }
    Navigator.of(context).pop();
    return Future(() => null);
  }

  Divider formDivider() {
    return const Divider(
      color: Colors.white,
      thickness: 0.2,
    );
  }

  Widget titleField() {
    return InputTextFormField(
      controller: title,
      hint: 'Title',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      validation: (String? val) {
        if (val == null || val.isEmpty) {
          return 'Name field can\'t be empty';
        }
        return null;
      },
    );
  }

  Widget descriptionField() {
    return InputTextFormField(
      controller: description,
      hint: 'Product description',
      maxLines: 6,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      validation: (String? val) {
        if (val == null || val.isEmpty) {
          return 'Description field can\'t be empty';
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
          return 'Price field can\'t be empty';
        }
        return null;
      },
    );
  }

  Widget buttonsBar() {
    return FutureBuilder(
        future: myFuture,
        builder: (c, s) => s.connectionState == ConnectionState.done
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      onPopupClose();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      _setIsPublishPressed();
                      if (_formKey.currentState!.validate() && isNew != null) {
                        final userId = (context
                                .read<UserBloc>()
                                .state
                                .props
                                .first as UserModel)
                            .id;
                        var uuid = const Uuid();
                        FirestoreService firestoreService = FirestoreService();
                        await firestoreService.createProduct(ProductModel(
                            id: uuid.v1(),
                            ownerId: userId,
                            name: title.text,
                            description: description.text,
                            isNew: isNew!,
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
                            images:
                                images.isEmpty ? [noImagePlaceholder] : images,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now()));
                        EasyLoading.showSuccess(
                            "Product was published successfully");
                        Navigator.of(context).pop();
                      }
                    },
                    // titleText: widget.productInfo == null ? 'Publish' : 'Update',
                    child: const Text('Publish'),
                  ),
                ],
              )
            : const CircularProgressIndicator.adaptive());
  }

  Widget productTypeToggle() {
    return Column(
      children: [
        FutureBuilder(
          future: myFuture,
          builder: (c, s) => s.connectionState == ConnectionState.done
              ? ToggleSwitch(
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
                )
              : const CircularProgressIndicator.adaptive(),
        ),
        if (isNew == null && isPublishPressed)
          const Text('Type selection is required',
              style: TextStyle(color: Colors.redAccent)),
      ],
    );
  }

  Widget categoryDropdown() {
    return FutureBuilder(
        future: myFuture,
        builder: (c, s) => s.connectionState == ConnectionState.done
            ? CategoriesDropdownMenu(
                onCategorySelected: _handleCategorySelection)
            : const CircularProgressIndicator.adaptive());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        onPopupClose();
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Hero(
            tag: _heroAddTodo,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin!, end: end!);
            },
            child: Material(
              color: AppColors.accentColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: <Widget>[
                            ImageUploadForm(
                                onImagesUploaded: _handleImageUpload),
                            formDivider(),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Column(children: [
                                  titleField(),
                                  formDivider(),
                                  descriptionField(),
                                  formDivider(),
                                  productTypeToggle(),
                                  formDivider(),
                                  priceField(),
                                  formDivider(),
                                  categoryDropdown(),
                                ])),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        right: 22.0,
                        top: MediaQuery.of(context).size.height * 0.6),
                    child: buttonsBar(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
