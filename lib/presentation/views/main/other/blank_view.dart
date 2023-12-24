import 'package:flutter/material.dart';

class BlankView extends StatelessWidget {
  const BlankView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            children: [],
          )),
    );
  }
}
