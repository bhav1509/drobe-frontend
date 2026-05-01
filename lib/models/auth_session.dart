class AuthSession {
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String? email;
  final String? displayName;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    this.email,
    this.displayName,
  });

  String get label {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final address = email?.trim();
    if (address != null && address.isNotEmpty) {
      return address;
    }

    return 'User #$userId';
  }
}
