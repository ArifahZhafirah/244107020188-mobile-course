class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

class AuthRepository {
  // Akun demo yang dianggap terdaftar di backend mock.
  // Ganti _demoPassword dengan sandi yang terisi otomatis di halaman login Anda.
  static const _demoEmail = 'arifah27@gmail.com';
  static const _demoPassword = '12345678';

  // GANTI titik ini dengan FirebaseAuth.instance.signInWithEmailAndPassword
  // atau GoogleSignIn saat backend Firebase sudah siap.
  Future<AuthSession> login(
      {required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.trim().toLowerCase() != _demoEmail || password != _demoPassword) {
      throw Exception('Email atau kata sandi salah');
    }
    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}