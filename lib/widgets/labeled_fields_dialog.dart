import 'package:flutter/material.dart';

class LabeledFieldsDialog extends StatefulWidget {
  const LabeledFieldsDialog({
    super.key,
    required this.title,
    required this.labels,
  });

  final String title;
  final List<String> labels;

  @override
  State<LabeledFieldsDialog> createState() => _LabeledFieldsDialogState();
}

class _LabeledFieldsDialogState extends State<LabeledFieldsDialog> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.labels
        .map((String label) => TextEditingController())
        .toList(growable: false);
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int index = 0; index < widget.labels.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _controllers[index],
                decoration: InputDecoration(labelText: widget.labels[index]),
              ),
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(<String, String>{
            for (int index = 0; index < widget.labels.length; index++)
              widget.labels[index]: _controllers[index].text.trim(),
          }),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
