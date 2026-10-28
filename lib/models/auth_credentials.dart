class EmailCredentials {
  final String email;
  final String password;

  const EmailCredentials({
    required this.email,
    required this.password,
  });
}

class PhoneCredentials {
  final String phoneNumber;
  final String smsCode;

  const PhoneCredentials({
    required this.phoneNumber,
    required this.smsCode,
  });
}