abstract class Repository {
  Future<bool> get isLoggedIn;

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

}