import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppFormField extends StatefulWidget {
  const AppFormField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  TextEditingController? _localController;
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    if (widget.controller == null) {
      _localController = TextEditingController();
    }
  }

  @override
  void didUpdateWidget(covariant AppFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscure = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        widget.controller ?? _localController!;
    final bool isPassword = widget.obscureText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.forest,
            ),
          ),
          const SizedBox(height: 7),
        ],
        TextFormField(
          controller: controller,
          obscureText: _obscure,
          maxLines: isPassword ? 1 : widget.maxLines,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.errorText == null ? widget.helper : null,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, color: AppColors.muted, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.muted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
