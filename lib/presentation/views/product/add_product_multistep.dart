import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/constant/collections.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/data/models/product/price_tag_model.dart';
import 'package:spoto/data/models/product/product_model.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/domain/usecases/product/update_product_usecase.dart';
import 'package:spoto/presentation/blocs/product/product_bloc.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/views/product/add_product_pages/add_product_form.dart';
import 'package:spoto/presentation/views/product/add_product_pages/confirm_contacts_form.dart';
import 'package:spoto/presentation/widgets/adaptive_alert_dialog.dart';
import 'package:spoto/presentation/widgets/add_product_flow/src.dart';
import 'package:spoto/presentation/widgets/address/place_service.dart';
import 'package:spoto/presentation/widgets/input_image_upload.dart';
import 'package:uuid/uuid.dart';

class AddProductMultiStepForm extends StatefulWidget {
  final Product? productInfo;
  final String? pageKey;

  const AddProductMultiStepForm({
    super.key,
    this.pageKey,
    this.productInfo,
  });

  @override
  State<AddProductMultiStepForm> createState() =>
      _AddProductMultiStepFormState();
}

class _AddProductMultiStepFormState extends State<AddProductMultiStepForm> {
  List<String> images = [];
  String? category;
  String? name;
  String? description;
  String? price;
  bool? isNew;
  Place? location;
  String? contactName;
  String? phoneNumber;

  final _detailsFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();

  void _handleImageUpload(List<String> imageURLs) {
    setState(() {
      images = imageURLs;
    });
  }

  void _handleChangingName(String newName) {
    setState(() {
      name = newName;
    });
  }

  void _handleChangingDescription(String newDescription) {
    setState(() {
      description = newDescription;
    });
  }

  void _handleChangingPrice(String newPrice) {
    setState(() {
      price = newPrice;
    });
  }

  void _handleAddingCategory(String newCategory) {
    setState(() {
      category = newCategory;
    });
  }

  void _handleChangingType(bool newType) {
    setState(() {
      isNew = newType;
    });
  }

  void _handleChangingLocation(Place newLocation) {
    setState(() {
      location = newLocation;
    });
  }

  void _handleChangingContactName(String newContactName) {
    setState(() {
      contactName = newContactName;
    });
  }

  void _handleChangingPhoneNumber(String newPhoneNumber) {
    setState(() {
      phoneNumber = newPhoneNumber;
    });
  }

  bool isExistingProductUpdated() {
    return name != widget.productInfo!.name ||
        description != widget.productInfo!.description ||
        isNew != widget.productInfo!.isNew ||
        images != widget.productInfo!.images ||
        category != widget.productInfo!.category ||
        double.parse(price!) != widget.productInfo!.price;
  }

  bool isProductInfoUpdated() {
    return name != null ||
        description != null ||
        isNew != null ||
        images.isNotEmpty ||
        category != null ||
        price != null;
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
    Navigator.pop(context);
    return Future(() => null);
  }

  void updateButtonAction() {
    final updatedModel = ProductModel(
        id: widget.productInfo!.id,
        ownerId: widget.productInfo!.ownerId,
        name: name!,
        description: description!,
        isNew: isNew!,
        status: ProductStatus.active,
        price: double.parse(price!.replaceAll(",", ".")),
        priceTags: [
          PriceTagModel(
              id: '1',
              name: "base",
              price: double.parse(price!.replaceAll(",", ".")))
        ],
        // categories: [CategoryModel.fromEntity(selectedCategory!)],
        category: category!,
        contactName: contactName!,
        contactPhone: phoneNumber ?? "",
        location: location!.toString(),
        images: images.isEmpty ? [] : images,
        createdAt: widget.productInfo!.createdAt,
        updatedAt: DateTime.now());
    context.read<ProductBloc>().add(UpdateProduct(UpdateProductParams(
        product: updatedModel, isPublicationsAction: false)));
    EasyLoading.showSuccess(productUpdatedSuccessfully);
    Navigator.of(context).pop();
  }

  void publishButtonAction() async {
    final currentState = context.read<UserBloc>().state;
    if (currentState is UserLoggedFail) {
      EasyLoading.showError("Please login to publish your product");
    } else {
      final userId = (currentState.props.first as UserModel).id;
      var uuid = const Uuid();
      final updatedModel = ProductModel(
          id: uuid.v1(),
          ownerId: userId,
          name: name!,
          description: description!,
          isNew: isNew!,
          status: ProductStatus.active,
          price: double.parse(price!.replaceAll(",", ".")),
          priceTags: [
            PriceTagModel(
                id: '1',
                name: "base",
                price: double.parse(price!.replaceAll(",", ".")))
          ],
          category: category!,
          images: images.isEmpty ? [] : images,
          contactName: contactName!,
          contactPhone: phoneNumber ?? "",
          location: location!.toString(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      context.read<ProductBloc>().add(AddProduct(updatedModel));
      EasyLoading.showSuccess(productPublishedSuccessfully);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    final currentState = context.read<UserBloc>().state;
    if (currentState is UserLoggedFail || currentState is UserLoggedOut) {
      Future.delayed(
          const Duration(milliseconds: 600),
          () => {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const SignInToUseFeatureAlert(
                        contentText: addProductPageUnavailable);
                  },
                )
              });
    } else {
      final currentUser = currentState.props.first as UserModel;
      setState(() {
        contactName = currentUser.name;
        phoneNumber = currentUser.phoneNumber;
      });
      if (widget.productInfo != null) {
        images = widget.productInfo!.images;
        category = widget.productInfo!.category;
        name = widget.productInfo!.name;
        description = widget.productInfo!.description;
        price = widget.productInfo!.priceTags.first.price.toString();
        isNew = widget.productInfo!.isNew;
        location = Place.fromJsonString(widget.productInfo!.location);
        phoneNumber = widget.productInfo!.contactPhone;
        contactName = widget.productInfo!.contactName;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoOnboarding(
      editPageKey: widget.pageKey,
      secondFormKey: _detailsFormKey,
      thirdFormKey: _contactFormKey,
      bottomButtonChild: const Text(nextTitle),
      scrollPhysics: const NeverScrollableScrollPhysics(),
      onPressedOnFirstPage: () => onPopupClose(),
      onPressedOnLastPage: () => widget.productInfo == null
          ? publishButtonAction()
          : updateButtonAction(),
      pages: [
        if ((widget.productInfo != null && widget.pageKey == "pictures") ||
            widget.productInfo == null)
          StepFormPage(
            title: Text(widget.pageKey == null
                ? uploadPicturesTitle
                : "Update Pictures"),
            features: [
              const WhatsNewFeature(
                description: Text(addImagesDetails),
              ),
              ImageUploadForm(
                  onImagesUploaded: _handleImageUpload, existingImages: images),
            ],
          ),
        if ((widget.productInfo != null && widget.pageKey == "details") ||
            widget.productInfo == null)
          StepFormPage(
            title: Text(
                widget.pageKey == null ? addDetailsTitle : "Update Details"),
            features: [
              AddProductForm(
                productInfo: widget.productInfo,
                formKey: _detailsFormKey,
                onNameChanged: _handleChangingName,
                onDescriptionChanged: _handleChangingDescription,
                onPriceChanged: _handleChangingPrice,
                onTypeChanged: _handleChangingType,
                onCategoryChanged: _handleAddingCategory,
              ),
            ],
          ),
        if ((widget.productInfo != null && widget.pageKey == "contact") ||
            widget.productInfo == null)
          StepFormPage(
            title: Text(
                widget.pageKey == null ? contactInfoTitle : "Update Contacts"),
            features: [
              const WhatsNewFeature(
                description: Text(contactInfoDetails),
              ),
              ConfirmContactsForm(
                contactName: contactName,
                contactLocation: location,
                contactPhoneNumber: phoneNumber,
                formKey: _contactFormKey,
                onLocationChanged: _handleChangingLocation,
                onContactNameChanged: _handleChangingContactName,
                onPhoneNumberChanged: _handleChangingPhoneNumber,
              ),
            ],
          ),
      ],
    );
  }
}
