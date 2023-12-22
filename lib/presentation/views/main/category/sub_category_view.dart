import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spoto/domain/entities/category/category.dart';
import 'package:spoto/presentation/widgets/sub_category_item.dart';

class SubCategoryView extends StatefulWidget {
  final Category category;

  const SubCategoryView({Key? key, required this.category}) : super(key: key);

  @override
  State<SubCategoryView> createState() => _SubCategoryViewState();
}

class _SubCategoryViewState extends State<SubCategoryView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 500,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: (MediaQuery.of(context).padding.top),
            ),
            Row(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                  },
                  child: const Row(
                    children: [
                      Icon(
                        CupertinoIcons.back,
                        color: CupertinoColors.black,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Category",
                        style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w400,
                            color: CupertinoColors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(widget.category.name,
                style: const TextStyle(
                    fontSize: 30,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black)),
            const SizedBox(
              height: 10,
            ),
            SubCategoryItemCard(
              subcategory: "All ${widget.category.name}",
            ),
            Expanded(
              // add builder implementation based on final List<String>? subCategories; from line 10
              child: ListView.builder(
                itemCount: widget.category.subcategory.length,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                    top: 0,
                    bottom: (80 + MediaQuery.of(context).padding.bottom)),
                itemBuilder: (context, index) => SubCategoryItemCard(
                  subcategory: widget.category.subcategory[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
