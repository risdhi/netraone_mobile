import 'package:flutter/material.dart';

class Brand extends StatelessWidget {
  final double height;
  const Brand({super.key, this.height = 80});
  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('assets/netraone_logo_final.png', height: height),
      ]);
}
