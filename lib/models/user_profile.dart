class UserProfile {
  final String title;
  final String lastName;
  final String birthName;
  final String firstName;
  final String nickname;
  final String birthDate;
  final String country;

  UserProfile({
    required String title,
    required String lastName,
    required String birthName,
    required String firstName,
    required String nickname,
    required String birthDate,
    required String country,
  })  : title = _sanitize(title),
        lastName = _sanitize(lastName),
        birthName = _sanitize(birthName),
        firstName = _sanitize(firstName),
        nickname = _sanitize(nickname),
        birthDate = _sanitize(birthDate),
        country = _sanitize(country);

  static String _sanitize(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      title: map['title'] as String? ?? 'M.',
      lastName: map['lastName'] as String? ?? '',
      birthName: map['birthName'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      nickname: map['nickname'] as String? ?? '',
      birthDate: map['birthDate'] as String? ?? '',
      country: map['country'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'lastName': lastName,
      'birthName': birthName,
      'firstName': firstName,
      'nickname': nickname,
      'birthDate': birthDate,
      'country': country,
    };
  }
}