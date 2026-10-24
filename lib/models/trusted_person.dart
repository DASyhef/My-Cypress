enum TrustedPersonStatus {
  notSent,
  pending,
  accepted,
  declined,
}

class TrustedPerson {
  final String id;
  final String lastName;
  final String firstName;
  final String email;
  final TrustedPersonStatus status;
  final String? videoUrl;

  TrustedPerson({
    required String id,
    required String lastName,
    required String firstName,
    required String email,
    required this.status,
    String? videoUrl,
  })  : id = _sanitize(id),
        lastName = _sanitize(lastName),
        firstName = _sanitize(firstName),
        email = _sanitize(email),
        videoUrl = videoUrl != null ? _sanitize(videoUrl) : null;

  TrustedPerson copyWith({
    String? id,
    String? lastName,
    String? firstName,
    String? email,
    TrustedPersonStatus? status,
    String? videoUrl,
  }) {
    return TrustedPerson(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      status: status ?? this.status,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  static String _sanitize(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'lastName': lastName,
      'firstName': firstName,
      'email': email,
      'status': status.name,
      'videoUrl': videoUrl,
    };
  }

  factory TrustedPerson.fromJson(Map<String, dynamic> json) {
    return TrustedPerson(
      id: json['id'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: TrustedPersonStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String?),
        orElse: () => TrustedPersonStatus.notSent,
      ),
      videoUrl: json['videoUrl'] as String?,
    );
  }
}