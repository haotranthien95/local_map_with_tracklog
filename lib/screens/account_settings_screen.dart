// T081-T084: AccountSettingsScreen for changing email and password

import 'package:flutter/material.dart';
import '../services/authentication_service.dart';
import '../features/auth/validators/email_validator.dart';
import '../features/auth/validators/password_validator.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/auth_text_field.dart';

/// T081: Account settings screen for email and password changes
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _authService = AuthenticationService();
  bool _isLoading = false;

  // T082: Show change email dialog
  Future<void> _showChangeEmailDialog() async {
    final newEmailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your new email address. A verification email will be sent to the new address.',
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: newEmailController,
                label: 'New Email',
                hint: 'Enter new email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!EmailValidator.isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: passwordController,
                label: 'Current Password',
                hint: 'Confirm your password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Change Email'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.updateEmail(
          newEmailController.text.trim(),
          passwordController.text,
        );

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Email updated to ${newEmailController.text.trim()}. '
              'Please check your inbox to verify.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      } on Exception catch (e) {
        if (!mounted) return;

        // T084: Handle requires-recent-login error
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.contains('requires-recent-login') ||
            errorMessage.contains('recent authentication')) {
          _showReauthenticationDialog(() => _showChangeEmailDialog());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    newEmailController.dispose();
    passwordController.dispose();
  }

  // T083: Show change password dialog
  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuthTextField(
                    controller: currentPasswordController,
                    label: 'Current Password',
                    obscureText: obscureCurrentPassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Current password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: newPasswordController,
                    label: 'New Password',
                    obscureText: obscureNewPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'New password is required';
                      }
                      if (!PasswordValidator.isValidPassword(value)) {
                        return PasswordValidator.getValidationError(value);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: confirmPasswordController,
                    label: 'Confirm New Password',
                    obscureText: obscureConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Password must be at least 8 characters with uppercase, lowercase, and number',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.changePassword(
          currentPasswordController.text,
          newPasswordController.text,
        );

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } on Exception catch (e) {
        if (!mounted) return;

        // T084: Handle requires-recent-login error
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.contains('requires-recent-login') ||
            errorMessage.contains('recent authentication')) {
          _showReauthenticationDialog(() => _showChangePasswordDialog());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  // T084: Show re-authentication dialog when recent login is required
  Future<void> _showReauthenticationDialog(VoidCallback retryAction) async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Re-authentication Required'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'For security reasons, please sign in again to continue.',
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: passwordController,
                label: 'Password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // TODO: Actually re-authenticate here
      // For now, just retry the action
      retryAction();
    }

    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Updating settings...',
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Change Email button
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Change Email'),
                subtitle: const Text('Update your email address'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showChangeEmailDialog,
              ),
            ),
            const SizedBox(height: 12),

            // Change Password button
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                subtitle: const Text('Update your password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showChangePasswordDialog,
              ),
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 32),

            // Info text
            Text(
              'Changes to your email or password may require you to sign in again.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Danger Zone
            const Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),

            // T089: Delete Account button with warning styling
            // T012: Updated to navigate to new delete account flow (Feature 004)
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text(
                  'Permanently delete your account and all data',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: () {
                  // T012: Navigate to delete account flow screen
                  Navigator.of(context).pushNamed('/delete_account');
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // T090-T093: Delete account confirmation and execution
  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // T090: Confirmation dialog with warning
    final confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        backgroundColor: Colors.red.shade50,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This cannot be undone!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Deleting your account will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• Permanently remove all your account data',
                style: TextStyle(color: Colors.grey[700])),
            Text('• Delete all your saved tracklogs', style: TextStyle(color: Colors.grey[700])),
            Text('• Cancel any active sessions', style: TextStyle(color: Colors.grey[700])),
            Text('• Remove your profile information', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 16),
            const Text(
              'To confirm, enter your password:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: formKey,
              child: AuthTextField(
                controller: passwordController,
                label: 'Password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmDelete == true && mounted) {
      // T091-T093: Execute account deletion
      setState(() {
        _isLoading = true;
      });

      try {
        final password = passwordController.text;

        // Delete account (Legacy method - kept for reference but not used)
        await _authService.deleteAccount(password: password);

        if (!mounted) return;

        // T092: Success flow - clear navigation and redirect to login
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } on Exception catch (e) {
        if (!mounted) return;

        // T093: Error handling
        final errorMessage = e.toString().replaceAll('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    passwordController.dispose();
  }
}
