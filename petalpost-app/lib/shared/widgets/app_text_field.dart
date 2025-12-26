import "package:flutter/material.dart";

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.suffix,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffix,
      ),
    );
  }
}
