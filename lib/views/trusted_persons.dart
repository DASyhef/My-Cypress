import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gontran/l10n/app_localizations.dart';
import 'package:gontran/services/auth_service.dart';
import '../models/trusted_person.dart';

class TrustedPersons extends StatefulWidget {
  const TrustedPersons({super.key});

  @override
  State<TrustedPersons> createState() => _TrustedPersonsState();
}

class _TrustedPersonsState extends State<TrustedPersons> {
  final List<TrustedPerson> _trustedPersons = [];
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isAdding = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _editingPersonId;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTrustedPersons();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadTrustedPersons() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trusted_persons')
          .get();

      setState(() {
        _trustedPersons.clear();
        for (var doc in snapshot.docs) {
          _trustedPersons.add(TrustedPerson.fromJson(doc.data()));
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(TrustedPersonStatus status) {
    switch (status) {
      case TrustedPersonStatus.notSent:
        return Colors.grey;
      case TrustedPersonStatus.pending:
        return Colors.orange;
      case TrustedPersonStatus.accepted:
        return Colors.green;
      case TrustedPersonStatus.declined:
        return Colors.red;
    }
  }

  String _getStatusLabel(TrustedPersonStatus status, AppLocalizations l10n) {
    switch (status) {
      case TrustedPersonStatus.notSent:
        return l10n.statusNotSent;
      case TrustedPersonStatus.pending:
        return l10n.statusPending;
      case TrustedPersonStatus.accepted:
        return l10n.statusAccepted;
      case TrustedPersonStatus.declined:
        return l10n.statusDeclined;
    }
  }

  void _startAdding() {
    setState(() {
      _editingPersonId = null;
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _isAdding = true;
    });
  }

  void _startEditing(TrustedPerson person) {
    setState(() {
      _editingPersonId = person.id;
      _firstNameController.text = person.firstName;
      _lastNameController.text = person.lastName;
      _emailController.text = person.email;
      _isAdding = true;
    });
  }

  Future<void> _savePerson(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final personId = _editingPersonId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    TrustedPersonStatus currentStatus = TrustedPersonStatus.notSent;
    if (_editingPersonId != null) {
      final existing = _trustedPersons.firstWhere((p) => p.id == _editingPersonId);
      currentStatus = existing.status;
    }

    final person = TrustedPerson(
      id: personId,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      status: currentStatus,
    );

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trusted_persons')
          .doc(personId)
          .set(person.toJson());

      if (mounted) {
        setState(() {
          if (_editingPersonId != null) {
            final index = _trustedPersons.indexWhere((p) => p.id == _editingPersonId);
            if (index != -1) {
              _trustedPersons[index] = person;
            }
          } else {
            _trustedPersons.add(person);
          }
          _firstNameController.clear();
          _lastNameController.clear();
          _emailController.clear();
          _formKey.currentState!.reset();
          _isAdding = false;
          _editingPersonId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
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

  Future<void> _confirmAndDeletePerson(String id, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteButton, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = _authService.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trusted_persons')
          .doc(id)
          .delete();

      if (mounted) {
        setState(() {
          _trustedPersons.removeWhere((p) => p.id == id);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trustedPersonsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              l10n.trustedPersonsDescription,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_trustedPersons.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trustedPersons.length,
                itemBuilder: (context, index) {
                  final person = _trustedPersons[index];
                  return Card(
                    child: ListTile(
                      title: Text('${person.firstName} ${person.lastName}'),
                      subtitle: Text(person.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(person.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getStatusColor(person.status)),
                            ),
                            child: Text(
                              _getStatusLabel(person.status, l10n),
                              style: TextStyle(color: _getStatusColor(person.status), fontSize: 12),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, size: 20, color: theme.colorScheme.primary),
                            onPressed: () => _startEditing(person),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 20, color: theme.colorScheme.secondary),
                            onPressed: () => _confirmAndDeletePerson(person.id, l10n),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            if (!_isAdding && _trustedPersons.length < 3) ...[
              ElevatedButton(
                onPressed: _startAdding,
                child: Text(l10n.addTrustedPerson),
              ),
            ] else if (_isAdding) ...[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _editingPersonId == null ? l10n.addPersonTitle : l10n.editPersonTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: theme.colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              _isAdding = false;
                              _editingPersonId = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: l10n.firstName),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.fieldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: l10n.lastName),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.fieldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: l10n.email),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.fieldRequired;
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return l10n.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : () => _savePerson(l10n),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_editingPersonId == null ? l10n.addTrustedPerson : l10n.saveChangesButton),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}