// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get signOutTooltip => 'Se déconnecter';

  @override
  String get welcomeMessage => 'Bienvenue';

  @override
  String get defaultUserFallback => 'Utilisateur';

  @override
  String get profileCardTitle => 'Profil';

  @override
  String get settingsCardTitle => 'Paramètres';

  @override
  String get profilePageTitle => 'État civil';

  @override
  String get profileLoadError => 'Erreur lors du chargement du profil :';

  @override
  String get profileSaveSuccess => 'État civil enregistré avec succès';

  @override
  String get profileSaveError => 'Erreur lors de la sauvegarde :';

  @override
  String get titleLabel => 'Titre';

  @override
  String get lastNameLabel => 'Nom *';

  @override
  String get lastNameError => 'Veuillez renseigner votre nom';

  @override
  String get birthNameLabel => 'Nom de naissance';

  @override
  String get firstNameLabel => 'Prénom(s) *';

  @override
  String get firstNameError => 'Veuillez renseigner votre prénom';

  @override
  String get nicknameLabel => 'Surnom';

  @override
  String get profileSensibilisationMessage =>
      'Sensibilisation : Vos volontés ont une valeur légale et morale. Il est primordial d\'indiquer votre vraie identité pour éviter tout litige lors de leur exécution.';

  @override
  String get birthDateLabel => 'Date de naissance *';

  @override
  String get birthDateError => 'Veuillez renseigner votre date de naissance';

  @override
  String get countryLabel => 'Pays';

  @override
  String get saveProfileButton => 'Enregistrer l\'état civil';

  @override
  String get trustedPersonsTitle => 'Personnes de confiance';

  @override
  String get trustedPersonsDescription =>
      'Choisissez jusqu\'à 3 personnes de confiance. Un envoi de mail automatique sera effectué.';

  @override
  String get addTrustedPerson => 'Ajouter une personne de confiance';

  @override
  String get statusNotSent => 'Mail pas envoyé';

  @override
  String get statusPending => 'Attente d\'une réponse';

  @override
  String get statusAccepted => 'Accepté';

  @override
  String get statusDeclined => 'Refusé';

  @override
  String get addPersonTitle => 'Ajouter une personne de confiance';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get email => 'E-mail';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String get fieldRequired => 'Ce champ est obligatoire';

  @override
  String get invalidEmail => 'Veuillez entrer un e-mail valide';

  @override
  String get editPersonTitle => 'Modifier le contact';

  @override
  String get confirmDeleteTitle => 'Confirmer la suppression';

  @override
  String get confirmDeleteContent =>
      'Voulez-vous vraiment supprimer ce contact de confiance ?';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get saveChangesButton => 'Enregistrer les modifications';

  @override
  String get sendButton => 'Envoyer';

  @override
  String invitationEmailBody(String firstName, String appUrl) {
    return 'Bonjour $firstName,\n\nVous avez été désigné comme personne de confiance sur My-Cypress.\n\nVous pouvez télécharger l\'application ou vous connecter en ligne ici : $appUrl';
  }
}
