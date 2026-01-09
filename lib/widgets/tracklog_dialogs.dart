import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../l10n/l10n_extension.dart';

/// Show dialog to input/edit tracklog name
Future<String?> showNameDialog(
  BuildContext context, {
  String? initialValue,
  String? title,
}) async {
  final controller = TextEditingController(text: initialValue ?? '');
  final formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title ??
          (initialValue == null ? context.l10n.nameTracklog : context.l10n.renameTracklog)),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: context.l10n.name,
            hintText: context.l10n.enterTracklogName,
          ),
          autofocus: true,
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.nameCannotBeEmpty;
            }
            return null;
          },
          onFieldSubmitted: (_) {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, controller.text.trim());
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: Text(context.l10n.ok),
        ),
      ],
    ),
  );
}

/// Show color picker dialog to select tracklog color
Future<Color?> showColorPickerDialog(
  BuildContext context, {
  required Color currentColor,
}) async {
  Color selectedColor = currentColor;

  return showDialog<Color>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.chooseColor),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: currentColor,
          onColorChanged: (color) {
            selectedColor = color;
          },
          availableColors: const [
            Colors.red,
            Colors.pink,
            Colors.purple,
            Colors.deepPurple,
            Colors.indigo,
            Colors.blue,
            Colors.lightBlue,
            Colors.cyan,
            Colors.teal,
            Colors.green,
            Colors.lightGreen,
            Colors.lime,
            Colors.yellow,
            Colors.amber,
            Colors.orange,
            Colors.deepOrange,
            Colors.brown,
            Colors.grey,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedColor),
          child: Text(context.l10n.ok),
        ),
      ],
    ),
  );
}

/// Show confirmation dialog before deleting a tracklog
Future<bool> showDeleteConfirmation(
  BuildContext context, {
  required String tracklogName,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove Tracklog'),
      content: Text(
        'Are you sure you want to remove "$tracklogName"?\n\nThis action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  return result ?? false;
}
