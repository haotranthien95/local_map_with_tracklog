// T076-T080: ProfileScreen for viewing and editing user profile

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/authentication_service.dart';
import '../services/profile_photo_service.dart';
import '../models/user.dart';
import '../widgets/loading_overlay.dart';
import 'account_settings_screen.dart';
import 'package:local_map_with_tracklog/l10n/l10n_extension.dart';
import '../models/profile_photo.dart';

/// T076: Profile screen to display and edit user information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthenticationService();
  final ProfilePhotoService _profilePhotoService = const ProfilePhotoService();
  final _displayNameController = TextEditingController();

  User? _currentUser;
  ProfilePhoto? _localProfilePhoto;
  bool _isLoading = false;
  bool _isEditingName = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadLocalProfilePhoto();
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

  Future<void> _loadLocalProfilePhoto() async {
    final photo = await _profilePhotoService.getProfilePhoto();
    if (!mounted) return;
    setState(() {
      _localProfilePhoto = photo;
    });
  }

  void _showPhotoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();

    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        _showPhotoSnackBar(context.l10n.photoPickerCancelled);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final saved = await _profilePhotoService.saveFromFilePath(picked.path);
      if (!mounted) return;

      setState(() {
        _localProfilePhoto = saved;
      });
    } on PlatformException {
      _showPhotoSnackBar(context.l10n.photoPermissionDenied);
    } catch (_) {
      _showPhotoSnackBar(context.l10n.photoPickerFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        SnackBar(
          content: Text(context.l10n.displayNameUpdatedSuccessfully),
          backgroundColor: Theme.of(context).primaryColor,
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
        title: Text(context.l10n.connectionError),
        content: Text(context.l10n.unableToUpdateProfile),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveDisplayName();
            },
            child: Text(context.l10n.retry),
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
        title: Text(context.l10n.profile),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: context.l10n.updating,
        child: _currentUser == null
            ? Center(
                child: Text(context.l10n.noUserSignedIn),
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
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: _localProfilePhoto != null
                                ? ClipOval(
                                    child: Image.file(
                                      File(_localProfilePhoto!.localPath),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Theme.of(context).primaryColor,
                                        );
                                      },
                                    ),
                                  )
                                : _currentUser!.photoUrl != null
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
                                              color: Theme.of(context).primaryColor,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Theme.of(context).primaryColor,
                                      ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _changeProfilePicture,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(context.l10n.changeProfilePicture),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentUser!.displayName ?? context.l10n.anonymousUser,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentUser!.email,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
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
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
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
                                Text(
                                  context.l10n.displayName,
                                  style: const TextStyle(
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
                                    decoration: InputDecoration(
                                      hintText: context.l10n.editDisplayName,
                                      border: const OutlineInputBorder(),
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
                                        child: Text(context.l10n.cancel),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: _saveDisplayName,
                                        child: Text(context.l10n.save),
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
                            Text(
                              context.l10n.accountInformation,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context.l10n.email,
                              _currentUser!.email,
                              Icons.email,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              context.l10n.emailVerified,
                              _currentUser!.emailVerified ? 'Yes' : 'No',
                              _currentUser!.emailVerified ? Icons.verified : Icons.warning,
                              valueColor: _currentUser!.emailVerified
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.error,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Provider',
                              _getProviderName(_currentUser!.authProvider),
                              Icons.security,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              context.l10n.memberSince,
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
                      label: Text(context.l10n.accountSettings),
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
        Icon(icon, size: 20, color: Theme.of(context).primaryColor.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
