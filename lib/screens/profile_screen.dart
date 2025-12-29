// T076-T080: ProfileScreen for viewing and editing user profile

import 'package:flutter/material.dart';
import '../services/authentication_service.dart';
import '../models/user.dart';
import '../widgets/loading_overlay.dart';
import 'account_settings_screen.dart';

/// T076: Profile screen to display and edit user information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthenticationService();
  final _displayNameController = TextEditingController();

  User? _currentUser;
  bool _isLoading = false;
  bool _isEditingName = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  // Load current user profile
  void _loadUserProfile() {
    setState(() {
      _currentUser = _authService.getCurrentUser();
      if (_currentUser != null) {
        _displayNameController.text = _currentUser!.displayName ?? '';
      }
    });
  }

  // T077: Edit display name functionality
  Future<void> _saveDisplayName() async {
    final newDisplayName = _displayNameController.text.trim();

    if (newDisplayName.isEmpty) {
      // T078: Error handling
      setState(() {
        _errorMessage = 'Display name cannot be empty';
      });
      return;
    }

    if (newDisplayName == _currentUser?.displayName) {
      setState(() {
        _isEditingName = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.updateDisplayName(newDisplayName);

      if (!mounted) return;

      // T079: Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isEditingName = false;
      });

      // Reload profile
      _loadUserProfile();
    } catch (e) {
      if (!mounted) return;

      // T078: Error handling
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      // T080: Offline detection
      if (e.toString().contains('network') || e.toString().contains('offline')) {
        _showOfflineRetryDialog();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // T080: Offline detection with retry option
  void _showOfflineRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: const Text(
          'Unable to update profile. Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveDisplayName();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // T086: Navigate to account settings
  void _navigateToAccountSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccountSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Updating profile...',
        child: _currentUser == null
            ? const Center(
                child: Text('No user signed in'),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile header with avatar
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue.shade100,
                            child: _currentUser!.photoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      _currentUser!.photoUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.blue.shade700,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.blue.shade700,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentUser!.displayName ?? 'Anonymous User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentUser!.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Error message display
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Display Name section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Display Name',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!_isEditingName)
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        _isEditingName = true;
                                        _displayNameController.text =
                                            _currentUser!.displayName ?? '';
                                      });
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_isEditingName)
                              Column(
                                children: [
                                  TextField(
                                    controller: _displayNameController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter display name',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _isEditingName = false;
                                            _errorMessage = null;
                                          });
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: _saveDisplayName,
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            else
                              Text(
                                _currentUser!.displayName ?? 'Not set',
                                style: const TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Account Info section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              'Email',
                              _currentUser!.email,
                              Icons.email,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Email Verified',
                              _currentUser!.emailVerified ? 'Yes' : 'No',
                              _currentUser!.emailVerified ? Icons.verified : Icons.warning,
                              valueColor:
                                  _currentUser!.emailVerified ? Colors.green : Colors.orange,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Provider',
                              _getProviderName(_currentUser!.authProvider),
                              Icons.security,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Member Since',
                              _formatDate(_currentUser!.createdAt),
                              Icons.calendar_today,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Account Settings button
                    ElevatedButton.icon(
                      onPressed: _navigateToAccountSettings,
                      icon: const Icon(Icons.settings),
                      label: const Text('Account Settings'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getProviderName(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.emailPassword:
        return 'Email/Password';
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
