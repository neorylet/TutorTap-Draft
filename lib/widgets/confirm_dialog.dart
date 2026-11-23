import 'package:flutter/material.dart';

class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.requiredText,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String? requiredText;

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  late final TextEditingController _controller;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _isEnabled = widget.requiredText == null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _isEnabled =
          value.trim().toLowerCase() ==
          widget.requiredText!.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.message),
          if (widget.requiredText != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              'Type "${widget.requiredText}" to confirm:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              autofocus: true,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isEnabled
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(widget.confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
