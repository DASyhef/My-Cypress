import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gontran/l10n/app_localizations.dart';
import 'package:gontran/models/user_profile.dart';
import 'package:gontran/services/auth_service.dart';
import 'package:gontran/views/dashboard_page.dart';
import 'package:gontran/views/trusted_persons.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  String _title = 'M.';
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  final List<String> _titleOptions = ['M.', 'Mme', 'Dr', 'Pr'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _birthNameController.dispose();
    _firstNameController.dispose();
    _nicknameController.dispose();
    _birthDateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final profile = UserProfile.fromMap(doc.data() ?? {});
        setState(() {
          if (_titleOptions.contains(profile.title)) {
            _title = profile.title;
          }
          _lastNameController.text = profile.lastName;
          _birthNameController.text = profile.birthName;
          _firstNameController.text = profile.firstName;
          _nicknameController.text = profile.nickname;
          _birthDateController.text = profile.birthDate;
          _countryController.text = profile.country;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${AppLocalizations.of(context)!.profileLoadError} $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final profile = UserProfile(
        title: _title,
        lastName: _lastNameController.text.trim(),
        birthName: _birthNameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        country: _countryController.text.trim(),
      );

      await _firestore.collection('users').doc(user.uid).update(profile.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileSaveSuccess)),
        );

        final trustedPersonsSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('trusted_persons')
            .limit(1)
            .get();

        if (mounted) {
          if (trustedPersonsSnapshot.docs.isEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TrustedPersons()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '${AppLocalizations.of(context)!.profileSaveError} $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profilePageTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<String>(
                    value: _title,
                    decoration: InputDecoration(
                      labelText: l10n.titleLabel,
                    ),
                    items: _titleOptions.map((title) {
                      return DropdownMenuItem(
                        value: title,
                        child: Text(title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _title = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: l10n.lastNameLabel,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.lastNameError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthNameController,
                    decoration: InputDecoration(
                      labelText: l10n.birthNameLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: l10n.firstNameLabel,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.firstNameError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: l10n.nicknameLabel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.profileSensibilisationMessage,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: _selectBirthDate,
                    decoration: InputDecoration(
                      labelText: l10n.birthDateLabel,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.birthDateError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      labelText: l10n.countryLabel,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.saveProfileButton),
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