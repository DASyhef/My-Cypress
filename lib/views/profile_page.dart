import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gontran/services/auth_service.dart';
import 'package:gontran/views/dashboard_page.dart';

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
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          if (data['title'] != null && _titleOptions.contains(data['title'])) {
            _title = data['title'];
          }
          _lastNameController.text = data['lastName'] ?? '';
          _birthNameController.text = data['birthName'] ?? '';
          _firstNameController.text = data['firstName'] ?? '';
          _nicknameController.text = data['nickname'] ?? '';
          _birthDateController.text = data['birthDate'] ?? '';
          _countryController.text = data['country'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du profil : $e';
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
      await _firestore.collection('users').doc(user.uid).update({
        'title': _title,
        'lastName': _lastNameController.text.trim(),
        'birthName': _birthNameController.text.trim(),
        'firstName': _firstNameController.text.trim(),
        'nickname': _nicknameController.text.trim(),
        'birthDate': _birthDateController.text.trim(),
        'country': _countryController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('État civil enregistré avec succès')),
        );
        // Redirection immédiate vers le dashboard après enregistrement
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la sauvegarde : $e';
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('État civil'),
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
                    decoration: const InputDecoration(
                      labelText: 'Titre',
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
                    decoration: const InputDecoration(
                      labelText: 'Nom *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez renseigner votre nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de naissance',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Prénom(s) *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez renseigner votre prénom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Surnom',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sensibilisation : Vos volontés ont une valeur légale et morale. '
                    'Il est primordial d\'indiquer votre vraie identité pour éviter tout '
                    'litige lors de leur exécution.',
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
                    decoration: const InputDecoration(
                      labelText: 'Date de naissance *',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez renseigner votre date de naissance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Pays',
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
                        : const Text('Enregistrer l\'état civil'),
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