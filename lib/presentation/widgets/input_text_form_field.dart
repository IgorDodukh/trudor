import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spoto/core/constant/messages.dart';

class InputTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final bool isSecureField;
  final bool autoCorrect;
  final String? hint;
  final EdgeInsets? contentPadding;
  final String? Function(String?)? validation;
  final double hintTextSize;
  final bool enable;
  final TextInputType textInputType;
  final int maxLines;
  final int maxCharacters;

  const InputTextFormField(
      {Key? key,
      required this.controller,
      this.isSecureField = false,
      this.autoCorrect = false,
      this.enable = true,
      this.textInputType = TextInputType.text,
      this.maxLines = 1,
      this.maxCharacters = 5000,
      this.hint,
      this.validation,
      this.contentPadding,
      this.hintTextSize = 16})
      : super(key: key);

  @override
  State<InputTextFormField> createState() => _InputTextFormFieldState();
}

class _InputTextFormFieldState extends State<InputTextFormField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.textInputType,
      inputFormatters: [
        LengthLimitingTextInputFormatter(widget.maxCharacters),
        widget.hint == priceHint
            ? FilteringTextInputFormatter.allow(RegExp(r'(^\d*[.,]?\d{0,2})'))
            : FilteringTextInputFormatter.deny(RegExp(r'')),
      ],
      controller: widget.controller,
      obscureText: widget.isSecureField && !_passwordVisible,
      enableSuggestions: !widget.isSecureField,
      autocorrect: widget.autoCorrect,
      validator: widget.validation,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      enabled: widget.enable,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black12,
        hintText: widget.hint,
        suffixText: widget.hint == priceHint ? "€" : null,
        hintStyle: TextStyle(
          fontSize: widget.hintTextSize,
        ),
        contentPadding: widget.contentPadding,
        suffixIcon: widget.isSecureField
            ? IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black87,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none),
      ),
    );
  }
}
