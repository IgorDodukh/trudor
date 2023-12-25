import 'package:flutter/material.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/presentation/widgets/address/address_search.dart';
import 'package:spoto/presentation/widgets/address/place_service.dart';
import 'package:spoto/presentation/widgets/input_text_form_field.dart';
import 'package:uuid/uuid.dart';

class ConfirmContactsForm extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final Product? productInfo;
  final String? contactName;
  final String? contactPhoneNumber;
  final Place? contactLocation;
  final ValueChanged<Place>? onLocationChanged;
  final ValueChanged<String>? onContactNameChanged;
  final ValueChanged<String>? onPhoneNumberChanged;

  const ConfirmContactsForm({
    super.key,
    this.formKey,
    this.productInfo,
    this.onLocationChanged,
    this.onContactNameChanged,
    this.onPhoneNumberChanged,
    this.contactName,
    this.contactPhoneNumber,
    this.contactLocation,
  });

  @override
  State<ConfirmContactsForm> createState() => _ConfirmContactsFormState();
}

class _ConfirmContactsFormState extends State<ConfirmContactsForm> {
  bool? isNew;
  int? initialLabelIndex;
  double formDividerHeight = 20;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  List<String> images = [];
  String? selectedCategory;

  @override
  void initState() {
    final String locationValue;
    if (widget.contactLocation!.areaLvl3 != "null") {
      locationValue = widget.contactLocation!.areaLvl3!;
    } else if (widget.contactLocation!.areaLvl2 != "null") {
      locationValue = widget.contactLocation!.areaLvl2!;
    } else if (widget.contactLocation!.areaLvl1 != "null") {
      locationValue = widget.contactLocation!.areaLvl1!;
    } else if (widget.contactLocation!.city != "null") {
      locationValue = widget.contactLocation!.city!;
    } else {
      locationValue = '';
    }
    super.initState();
    contactNameController.text = widget.contactName ?? '';
    phoneController.text = widget.contactPhoneNumber ?? '';
    locationController.text = locationValue;
  }

  Widget contactName() {
    return InputTextFormField(
      controller: contactNameController,
      hint: contactNameHint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      validation: (String? val) {
        if (val == null || val.isEmpty) {
          return nameValidation;
        }
        return null;
      },
      onChanged: (_) {
        setState(() {
          widget.onContactNameChanged!(contactNameController.text);
        });
        return null;
      },
    );
  }

  Widget phoneField() {
    return InputTextFormField(
      textInputType: TextInputType.phone,
      controller: phoneController,
      hint: phoneNumberHint,
      maxCharacters: 9,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      onChanged: (_) {
        setState(() {
          widget.onPhoneNumberChanged!(phoneController.text);
        });
        return null;
      },
    );
  }

  Widget pickupLocation() {
    return InputTextFormField(
      controller: locationController,
      readOnly: true,
      hint: chooseLocationHint,
      validation: (String? val) {
        if (val == null || val.isEmpty) {
          return locationValidation;
        }
        return null;
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      onTapAction: () async {
        final sessionToken = const Uuid().v4();
        final Suggestion? result = await showSearch(
          context: context,
          delegate: AddressSearch(sessionToken),
        );
        // This will change the text displayed in the TextField
        if (result != null) {
          final placeDetails = await PlaceApiProvider(sessionToken)
              .getPlaceDetailFromId(result.placeId);
          setState(() {
            print(placeDetails);
            if (placeDetails.areaLvl3 != null) {
              widget.onLocationChanged!(placeDetails);
              locationController.text = "${placeDetails.areaLvl3}";
            } else if (placeDetails.areaLvl2 != null) {
              widget.onLocationChanged!(placeDetails);
              locationController.text = "${placeDetails.areaLvl2}";
            } else if (placeDetails.areaLvl1 != null) {
              widget.onLocationChanged!(placeDetails);
              locationController.text = "${placeDetails.areaLvl1}";
            } else if (placeDetails.city != null) {
              widget.onLocationChanged!(placeDetails);
              locationController.text = "${placeDetails.city}";
            }
          });
        }
      },
    );
  }

  bool isExistingProductUpdated() {
    return nameController.text != widget.productInfo!.name ||
        contactNameController.text != widget.productInfo!.description ||
        isNew != widget.productInfo!.isNew ||
        images != widget.productInfo!.images ||
        selectedCategory != widget.productInfo!.category ||
        priceController.text !=
            widget.productInfo!.priceTags.first.price.toString();
  }

  bool isProductInfoUpdated() {
    return nameController.text.isNotEmpty ||
        contactNameController.text.isNotEmpty ||
        isNew != null ||
        images.isNotEmpty ||
        selectedCategory != null ||
        priceController.text.isNotEmpty;
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
                      SizedBox(height: formDividerHeight * 3),
                      pickupLocation(),
                      SizedBox(height: formDividerHeight),
                      contactName(),
                      SizedBox(height: formDividerHeight),
                      phoneField(),
                    ])),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
