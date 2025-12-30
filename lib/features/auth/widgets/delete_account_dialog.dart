// T009: Delete account confirmation dialog widget (Feature 004)

import 'package:flutter/material.dart';

/// Confirmation dialog for account deletion
///
/// Shows a warning message about permanent data loss and provides
/// Cancel and Delete buttons for user confirmation.
class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: const Text(
        'Are you sure you want to delete your account?\n\n'
        'This action cannot be undone and all your data will be permanently deleted, including:\n'
        '• All saved tracklogs\n'
        '• Map markers and locations\n'
        '• Profile information\n'
        '• App settings',
        style: TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  /// Show the delete confirmation dialog
  /// Returns true if user confirms deletion, false if cancelled
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DeleteAccountDialog(),
    );
    return result ?? false;
  }
}
