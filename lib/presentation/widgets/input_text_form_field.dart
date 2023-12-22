import 'package:flutter/cupertino.dart';
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
  final String? Function(String?)? onChanged;
  final double hintTextSize;
  final double? initialValue;
  final bool enable;
  final TextInputType textInputType;
  final int maxLines;
  final int maxCharacters;
  final dynamic onTapAction;
  final bool readOnly;

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
      this.onChanged,
      this.initialValue,
      this.contentPadding,
      this.onTapAction,
      this.readOnly = false,
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
      readOnly: widget.readOnly,
      keyboardType: widget.textInputType,
      inputFormatters: [
        LengthLimitingTextInputFormatter(widget.maxCharacters),
        widget.hint == priceHint ||
                widget.hint == minPriceHint ||
                widget.hint == maxPriceHint
            ? FilteringTextInputFormatter.allow(RegExp(r'(^\d*[.,]?\d{0,2})'))
            : FilteringTextInputFormatter.deny(RegExp(r'')),
      ],
      onTap: () {
        if (widget.hint == "Choose location") {
          widget.onTapAction();
        }
      },
      controller: widget.controller,
      obscureText: widget.isSecureField && !_passwordVisible,
      enableSuggestions: !widget.isSecureField,
      autocorrect: widget.autoCorrect,
      validator: widget.validation,
      onChanged: widget.onChanged,
      initialValue: widget.initialValue?.toString(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      enabled: widget.enable,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        prefixIcon: widget.hint == phoneNumberHint
            ? Container(
                margin: const EdgeInsets.only(left: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: InkWell(
                    onTap: null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(
                            width: 4,
                          ),
                          FittedBox(
                            child: Text(
                              '+351',
                              style: TextStyle(
                                fontSize: widget.hintTextSize,
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : widget.hint == "Choose location"
                ? const SizedBox(
                    width: 10,
                    height: 10,
                    child: Icon(
                      CupertinoIcons.location_solid,
                      color: Colors.black87,
                    ),
                  )
                : null,
        filled: true,
        fillColor: Colors.black12,
        hintText: widget.hint,
        suffixText: widget.hint == priceHint ||
                widget.hint == minPriceHint ||
                widget.hint == maxPriceHint
            ? "€"
            : null,
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
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none),
      ),
    );
  }
}
