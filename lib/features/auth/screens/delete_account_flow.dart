// T010: Delete account flow screen (Feature 004)

import 'package:flutter/material.dart';
import '../../../services/authentication_service.dart';
import '../widgets/delete_account_dialog.dart';

/// Screen that handles the delete account flow
///
/// Manages states: confirmation, loading, error (with retry/cancel), success
/// Navigates to sign-in screen after successful deletion
class DeleteAccountFlow extends StatefulWidget {
  const DeleteAccountFlow({super.key});

  @override
  State<DeleteAccountFlow> createState() => _DeleteAccountFlowState();
}

class _DeleteAccountFlowState extends State<DeleteAccountFlow> {
  final AuthenticationService _authService = AuthenticationService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _errorCode;
  String? _statusMessage; // T015: Progress messages

  @override
  void initState() {
    super.initState();
    // Show confirmation dialog immediately when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showConfirmationDialog();
    });
  }

  Future<void> _showConfirmationDialog() async {
    final confirmed = await DeleteAccountDialog.show(context);

    if (!mounted) return;

    if (confirmed) {
      await _performDeletion();
    } else {
      // User cancelled - go back
      Navigator.of(context).pop();
    }
  }

  Future<void> _performDeletion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorCode = null;
      _statusMessage = 'Verifying identity...'; // T015: Progress message
    });

    try {
      final result = await _authService.deleteAccount();

      if (!mounted) return;

      if (result.success) {
        // T015: Show final progress message before navigation
        setState(() {
          _statusMessage = 'Account deleted successfully';
        });

        // Brief delay to show success message
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Success - navigate to sign-in screen
        _navigateToSignIn();
      } else {
        // T018: Handle cancellation specifically
        if (result.errorCode == 'popup-closed-by-user' ||
            result.errorCode == 'cancelled-popup-request') {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Sign-in cancelled. Your account was not deleted.';
            _errorCode = result.errorCode;
          });
        } else {
          // Error - show error with retry/cancel buttons
          setState(() {
            _isLoading = false;
            _errorMessage = result.error ?? 'Account deletion failed';
            _errorCode = result.errorCode;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        _errorCode = 'unknown-error';
      });
    }
  }

  void _navigateToSignIn() {
    // Navigate to sign-in screen and clear navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  void _retry() {
    _performDeletion();
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  String _getProviderName() {
    // Attempt to determine provider from error context or user's linked accounts
    final user = _authService.getCurrentUser();
    if (user != null) {
      // Check which provider the user has linked
      final providers = _authService.getLinkedProviders();
      if (providers.contains('google.com')) {
        return 'Google';
      } else if (providers.contains('apple.com')) {
        return 'Apple';
      }
    }
    return 'Provider'; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
      ),
      body: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // Should not reach here as dialog is shown in initState
    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          _statusMessage ?? 'Deleting account...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'This may take a moment',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    // T023: Provider-specific error message mapping
    String displayMessage = _errorMessage ?? 'An error occurred';
    String? actionableHint;

    if (_errorCode == 'provider-revoked') {
      final provider = _getProviderName();
      actionableHint = 'Please re-enable this app in your $provider settings and try again.';
    } else if (_errorCode == 'network-request-failed') {
      actionableHint = 'Please check your internet connection and try again.';
    } else if (_errorCode == 'popup-closed-by-user' || _errorCode == 'cancelled-popup-request') {
      actionableHint = 'Sign-in was cancelled. Your account remains active.';
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Account Deletion Failed',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            displayMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionableHint != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      actionableHint,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_errorCode != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error code: $_errorCode',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _cancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _retry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
