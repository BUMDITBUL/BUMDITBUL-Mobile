import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/text_form_field/text_form_field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.focusNode,
    this.initialValue,
    this.style,
    this.decoration = const InputDecoration(),
    this.labelSpacing = 8,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.expands = false,
    this.showCursor,
    this.obscuringCharacter = '*',
    this.inputFormatters,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.height = 43,
    this.width,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? initialValue;

  final TextStyle? style;

  final InputDecoration? decoration;

  final double labelSpacing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;

  final bool autofocus;
  final bool readOnly;
  final bool obscureText;
  final bool autocorrect;
  final bool expands;
  final bool? showCursor;

  final String obscuringCharacter;

  final List<TextInputFormatter>? inputFormatters;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  final double? width;
  final double? height;

  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool get hasLabel =>
      widget.decoration != null &&
      (widget.decoration!.label != null ||
          widget.decoration!.labelText != null);

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _effectiveFocusNode.hasFocus);
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        _isFocused ? BumditbulColor.white : BumditbulColor.black800;

    final defaultTextStyle = BumditbulTextStyle.buttonLarge2
        .copyWith(color: textColor)
        .merge(widget.style);

    final decoration = widget.decoration;

    InputDecoration inputDecoration = InputDecoration(
      icon: decoration?.icon,
      iconColor: decoration?.iconColor,
      helper: decoration?.helper,
      helperText: decoration?.helperText,
      helperStyle: decoration?.helperStyle,
      helperMaxLines: decoration?.helperMaxLines,
      hintText: decoration?.hintText,
      hintStyle: decoration?.hintStyle,
      hintTextDirection: decoration?.hintTextDirection,
      hintMaxLines: decoration?.hintMaxLines,
      error: decoration?.error,
      errorText: decoration?.errorText,
      errorStyle: decoration?.errorStyle,
      errorMaxLines: decoration?.errorMaxLines,
      floatingLabelBehavior: decoration?.floatingLabelBehavior,
      floatingLabelAlignment: decoration?.floatingLabelAlignment,
      isCollapsed: decoration?.isCollapsed ?? false,
      isDense: decoration?.isDense,
      contentPadding: decoration?.contentPadding,
      prefixIcon: decoration?.prefixIcon,
      prefixIconConstraints: decoration?.prefixIconConstraints,
      prefix: decoration?.prefix,
      prefixText: decoration?.prefixText,
      prefixStyle: decoration?.prefixStyle,
      prefixIconColor: decoration?.prefixIconColor,
      suffixIcon: decoration?.suffixIcon,
      suffix: decoration?.suffix,
      suffixText: decoration?.suffixText,
      suffixStyle: decoration?.suffixStyle,
      suffixIconColor: decoration?.suffixIconColor,
      suffixIconConstraints: decoration?.suffixIconConstraints,
      counter: decoration?.counter,
      counterText: decoration?.counterText,
      counterStyle: decoration?.counterStyle,
      filled: decoration?.filled,
      fillColor: decoration?.fillColor,
      focusColor: decoration?.focusColor,
      hoverColor: decoration?.hoverColor,
      errorBorder: decoration?.errorBorder,
      focusedBorder: decoration?.focusedBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: BumditbulColor.green400),
          ),
      focusedErrorBorder: decoration?.focusedErrorBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: BumditbulColor.red),
          ),
      disabledBorder: decoration?.disabledBorder,
      enabledBorder: decoration?.enabledBorder,
      border: decoration?.border,
      enabled: decoration?.enabled ?? true,
      semanticCounterText: decoration?.semanticCounterText,
      alignLabelWithHint: decoration?.alignLabelWithHint,
      constraints: decoration?.constraints,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLabel) ...[
          CustomTextFormFieldLabel(
            label: widget.decoration!.label,
            labelText: widget.decoration!.labelText,
            labelStyle: widget.decoration!.labelStyle,
          ),
          SizedBox(height: widget.labelSpacing),
        ],
        TextFormField(
          autocorrect: widget.autocorrect,
          showCursor: widget.showCursor,
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _effectiveFocusNode,
          decoration: inputDecoration,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          style: defaultTextStyle,
          textAlign: widget.textAlign,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          cursorColor: BumditbulColor.green400,
          obscureText: widget.obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          expands: widget.expands,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onTapOutside: widget.onTapOutside,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onFieldSubmitted,
          onSaved: widget.onSaved,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
        ),
      ],
    );
  }
}
