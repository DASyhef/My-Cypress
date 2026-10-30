import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gontran/l10n/app_localizations.dart';
import 'package:gontran/models/auth_credentials.dart';
import 'package:gontran/services/auth_service.dart';
import 'package:gontran/theme/app_theme.dart';

class AuthPage extends StatefulWidget {
  final String? initialInfoMessage;
  const AuthPage({super.key, this.initialInfoMessage});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

enum AuthMode { email, phone }

enum AuthAction { login, register }

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  AuthMode _authMode = AuthMode.email;
  AuthAction _authAction = AuthAction.login;
  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();

  String? _verificationId;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _infoMessage = widget.initialInfoMessage;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail(AppLocalizations l10n) async {
    if (!_emailFormKey.currentState!.validate()) return;

    final credentials = EmailCredentials(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      if (_authAction == AuthAction.register) {
        AuthService.pendingAuthMessage = l10n.verificationEmailSent;
        await _authService.signUpWithEmail(
          email: credentials.email,
          password: credentials.password,
        );
      } else {
        await _authService.signInWithEmail(
          email: credentials.email,
          password: credentials.password,
        );
      }
    } catch (e) {
      AuthService.pendingAuthMessage = null;
      if (mounted) {
        setState(() {
          _errorMessage = e is FirebaseAuthException ? e.message : e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog(AppLocalizations l10n) {
    final resetController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialisation du mot de passe'),
        content: TextField(
          controller: resetController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: l10n.emailLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetController.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(context);
              try {
                await _authService.sendPasswordResetEmail(email);
                if (mounted) {
                  setState(() {
                    _infoMessage = 'E-mail de réinitialisation envoyé.';
                    _errorMessage = null;
                  });
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _errorMessage = e is FirebaseAuthException
                        ? e.message
                        : e.toString();
                  });
                }
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      if (_authAction == AuthAction.register) {
        await _authService.signUpWithGoogle();
      } else {
        await _authService.signInWithGoogle();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is FirebaseAuthException ? e.message : e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      if (_authAction == AuthAction.register) {
        await _authService.signUpWithApple();
      } else {
        await _authService.signInWithApple();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is FirebaseAuthException ? e.message : e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyPhone() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    final phoneNumber = _phoneController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.message;
          });
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
            _codeSent = true;
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _submitSmsCode() async {
    if (_verificationId == null) return;

    final credentials = PhoneCredentials(
      phoneNumber: _phoneController.text.trim(),
      smsCode: _smsCodeController.text.trim(),
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      if (_authAction == AuthAction.register) {
        await _authService.signUpWithSmsCode(
          verificationId: _verificationId!,
          smsCode: credentials.smsCode,
        );
      } else {
        await _authService.signInWithSmsCode(
          verificationId: _verificationId!,
          smsCode: credentials.smsCode,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is FirebaseAuthException ? e.message : e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.maxFormWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.authTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  _authAction == AuthAction.login
                      ? l10n.authLoginSubtitle
                      : l10n.authRegisterSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacingXl),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: AppTheme.errorContainerDecoration(theme),
                    child: Text(
                      _errorMessage!,
                      style: AppTheme.errorTextStyle(theme),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],
                if (_infoMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSm,
                      ),
                    ),
                    child: Text(
                      _infoMessage!,
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],
                if (_authMode == AuthMode.email)
                  _buildEmailForm(theme, l10n)
                else
                  _buildPhoneForm(theme, l10n),
                const SizedBox(height: AppTheme.spacingMd),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _authMode = _authMode == AuthMode.email
                          ? AuthMode.phone
                          : AuthMode.email;
                      _errorMessage = null;
                      _infoMessage = null;
                      _codeSent = false;
                    });
                  },
                  child: Text(
                    _authMode == AuthMode.email
                        ? l10n.usePhoneInstead
                        : l10n.useEmailInstead,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                const Divider(),
                const SizedBox(height: AppTheme.spacingMd),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  OutlinedButton.icon(
                    onPressed: _handleGoogleAuth,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: AppTheme.iconSizeLg,
                    ),
                    label: Text(
                      _authAction == AuthAction.login
                          ? l10n.continueWithGoogle
                          : l10n.signUpWithGoogle,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  OutlinedButton.icon(
                    onPressed: _handleAppleAuth,
                    icon: const Icon(Icons.apple, size: AppTheme.iconSizeMd),
                    label: Text(
                      _authAction == AuthAction.login
                          ? l10n.continueWithApple
                          : l10n.signUpWithApple,
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacingLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _authAction == AuthAction.login
                          ? l10n.noAccountYet
                          : l10n.alreadyHaveAccount,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _authAction = _authAction == AuthAction.login
                              ? AuthAction.register
                              : AuthAction.login;
                          _errorMessage = null;
                          _infoMessage = null;
                        });
                      },
                      child: Text(
                        _authAction == AuthAction.login
                            ? l10n.signUpButton
                            : l10n.signInButton,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(ThemeData theme, AppLocalizations l10n) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.emailLabel),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.invalidEmailError;
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.passwordLabel),
            validator: (value) {
              if (value == null || value.length < 6) {
                return l10n.passwordTooShortError;
              }
              return null;
            },
          ),
          if (_authAction == AuthAction.login) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(l10n),
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppTheme.spacingMd),
          ],
          ElevatedButton(
            onPressed: _isLoading ? null : () => _submitEmail(l10n),
            child: Text(
              _authAction == AuthAction.login
                  ? l10n.signInButton
                  : l10n.signUpButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm(ThemeData theme, AppLocalizations l10n) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        children: [
          if (!_codeSent) ...[
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.phoneLabel),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.invalidPhoneError;
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyPhone,
              child: Text(l10n.sendSmsCodeButton),
            ),
          ] else ...[
            TextFormField(
              controller: _smsCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.smsCodeLabel),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.invalidSmsCodeError;
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitSmsCode,
              child: Text(l10n.validateCodeButton),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _codeSent = false;
                  _verificationId = null;
                });
              },
              child: Text(l10n.editPhoneButton),
            ),
          ],
        ],
      ),
    );
  }
}
