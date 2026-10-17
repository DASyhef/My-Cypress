import 'package:flutter/material.dart';
import 'package:gontran/l10n/app_localizations.dart';
import '../models/trusted_person.dart';

class TrustedPersons extends StatefulWidget {
  const TrustedPersons({super.key});

  @override
  State<TrustedPersons> createState() => _TrustedPersonsState();
}

class _TrustedPersonsState extends State<TrustedPersons> {
  final List<TrustedPerson> _trustedPersons = [];

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

  void _showAddPersonDialog(BuildContext context, AppLocalizations l10n) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.addPersonTitle),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(labelText: l10n.firstName),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: l10n.lastName),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _trustedPersons.add(
                      TrustedPerson(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        firstName: firstNameController.text.trim(),
                        lastName: lastNameController.text.trim(),
                        email: emailController.text.trim(),
                        status: TrustedPersonStatus.notSent,
                      ),
                    );
                  });
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trustedPersonsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.trustedPersonsDescription,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _trustedPersons.length,
                itemBuilder: (context, index) {
                  final person = _trustedPersons[index];
                  return Card(
                    child: ListTile(
                      title: Text('${person.firstName} ${person.lastName}'),
                      subtitle: Text(person.email),
                      trailing: Container(
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
                    ),
                  );
                },
              ),
            ),
            if (_trustedPersons.length < 3)
              ElevatedButton(
                onPressed: () => _showAddPersonDialog(context, l10n),
                child: Text(l10n.addTrustedPerson),
              ),
          ],
        ),
      ),
    );
  }
}