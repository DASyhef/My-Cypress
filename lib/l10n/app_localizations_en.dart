// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get signOutTooltip => 'Sign out';

  @override
  String get welcomeMessage => 'Welcome';

  @override
  String get defaultUserFallback => 'User';

  @override
  String get profileCardTitle => 'Profile';

  @override
  String get settingsCardTitle => 'Settings';

  @override
  String get profilePageTitle => 'Civil Status';

  @override
  String get profileLoadError => 'Error loading profile:';

  @override
  String get profileSaveSuccess => 'Civil status saved successfully';

  @override
  String get profileSaveError => 'Error saving profile:';

  @override
  String get titleLabel => 'Title';

  @override
  String get lastNameLabel => 'Last Name *';

  @override
  String get lastNameError => 'Please enter your last name';

  @override
  String get birthNameLabel => 'Birth Name';

  @override
  String get firstNameLabel => 'First Name(s) *';

  @override
  String get firstNameError => 'Please enter your first name';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get profileSensibilisationMessage =>
      'Awareness: Your wishes have legal and moral value. It is essential to provide your true identity to avoid any dispute during their execution.';

  @override
  String get birthDateLabel => 'Date of Birth *';

  @override
  String get birthDateError => 'Please enter your date of birth';

  @override
  String get countryLabel => 'Country';

  @override
  String get saveProfileButton => 'Save Civil Status';

  @override
  String get trustedPersonsTitle => 'Trusted Persons';

  @override
  String get trustedPersonsDescription =>
      'Choose up to 3 trusted persons. An automatic email will be sent.';

  @override
  String get addTrustedPerson => 'Add trusted person';

  @override
  String get statusNotSent => 'Mail not sent';

  @override
  String get statusPending => 'Pending response';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusDeclined => 'Declined';

  @override
  String get addPersonTitle => 'Add a trusted person';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get email => 'Email';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get editPersonTitle => 'Edit contact';

  @override
  String get confirmDeleteTitle => 'Confirm deletion';

  @override
  String get confirmDeleteContent =>
      'Do you really want to delete this trusted person?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get saveChangesButton => 'Save changes';

  @override
  String get sendButton => 'Send';

  @override
  String invitationEmailBody(String firstName, String appUrl) {
    return 'Hello $firstName,\n\nYou have been designated as a trusted person on My-Cypress.\n\nYou can download the app or log in online here: $appUrl';
  }
}
