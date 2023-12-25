import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:spoto/core/router/app_router.dart';
import 'package:spoto/domain/entities/product/product.dart';

class EditProductModal {
  final Product product;

  EditProductModal(this.product);

  Future<void> openEditModal(BuildContext context) async {
    final result = await showModalActionSheet(
        context: context,
        title: "What would you like to update?",
        actions: [
          const SheetAction(
            label: "Pictures",
            key: "pictures",
          ),
          const SheetAction(label: "Details", key: "details"),
          const SheetAction(label: "Contact Info", key: "contact"),
        ]);
    if (result != null) {
      Navigator.of(context).pushNamed(
        AppRouter.addProduct,
        arguments: {"result": result, "product": product},
      );
    }
    ;
  }
}
