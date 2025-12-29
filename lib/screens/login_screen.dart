// T060-T068: LoginScreen for user authentication

import 'package:flutter/material.dart';
import '../services/authentication_service.dart';
import '../features/auth/validators/email_validator.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_login_buttons.dart';
import '../widgets/loading_overlay.dart';

/// T060: Login screen with email/password and social login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthenticationService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // T063: Validate login form
  bool _validateForm() {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return false;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Additional email validation
    if (!EmailValidator.isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return false;
    }

    // Basic password check
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Password is required';
      });
      return false;
    }

    return true;
  }

  // T055: Handle email/password login
  Future<void> _handleEmailPasswordLogin() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final result = await _authService.signInWithEmail(email, password);

      if (!mounted) return;

      if (result.success && result.user != null) {
        // T065: Success flow - navigate to home
        // T067: Check email verification
        if (!result.user!.emailVerified) {
          _showEmailVerificationReminder(result.user!.email);
        } else {
          _navigateToHome();
        }
      } else {
        // T064: Error handling - show user-friendly message
        setState(() {
          _errorMessage = result.error ?? 'Login failed';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // T057: Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (result.success && result.user != null) {
        // T065: Success - navigate to home
        _navigateToHome();
      } else {
        // T068: Handle cancellation gracefully
        if (result.errorCode == 'popup-closed-by-user') {
          setState(() {
            _errorMessage = 'Sign-in cancelled';
          });
        } else {
          setState(() {
            _errorMessage = result.error ?? 'Google sign-in failed';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // T058: Handle Apple Sign In
  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithApple();

      if (!mounted) return;

      if (result.success && result.user != null) {
        // T065: Success - navigate to home
        _navigateToHome();
      } else {
        // T068: Handle cancellation gracefully
        if (result.errorCode == 'popup-closed-by-user') {
          setState(() {
            _errorMessage = 'Sign-in cancelled';
          });
        } else {
          setState(() {
            _errorMessage = result.error ?? 'Apple sign-in failed';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // T066: Show forgot password dialog
  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController(text: _emailController.text.trim());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: emailController,
              label: 'Email',
              hint: 'Enter your email',
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (EmailValidator.isValidEmail(email)) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );

    if (result == true) {
      final email = emailController.text.trim();
      try {
        await _authService.sendPasswordReset(email);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send reset email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    emailController.dispose();
  }

  // T067: Show email verification reminder
  void _showEmailVerificationReminder(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Email Not Verified'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please verify your email address: $email'),
            const SizedBox(height: 8),
            const Text(
              'Check your inbox for the verification link.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToHome();
            },
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _authService.sendEmailVerification();
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification email sent'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
                _navigateToHome();
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to send verification email'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Resend'),
          ),
        ],
      ),
    );
  }

  // T065: Navigate to home screen on success
  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  // T072: Navigate to register screen
  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Signing in...',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // Logo or app name
                  const Icon(
                    Icons.map,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

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

                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // T066: Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign in button
                  AuthButton(
                    text: 'Sign In',
                    onPressed: _handleEmailPasswordLogin,
                    icon: const Icon(Icons.login),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // T061-T062: Social login buttons
                  SocialLoginButtons(
                    onGoogleSignIn: _handleGoogleSignIn,
                    onAppleSignIn: _handleAppleSignIn,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 32),

                  // T072: Navigate to register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account? ',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
