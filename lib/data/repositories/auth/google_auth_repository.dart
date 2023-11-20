import 'package:eshop/data/data_sources/local/user_local_data_source.dart';
import 'package:eshop/domain/auth/google_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthRepository {
  final GoogleSignIn _googleSignIn;

  GoogleAuthRepository() : _googleSignIn = GoogleSignIn(clientId: "251304641663-ti4h232vb33f3uk7rhsa1nm5rvrmpbf2.apps.googleusercontent.com");

  Future<GoogleAuth?> signIn() async {

    final GoogleSignInAccount? account = await _googleSignIn.signIn();

    if (_googleSignIn.currentUser != null) {
      print('User ID: ${_googleSignIn.currentUser?.id}');
    }

    // If the user did not sign in successfully, return null
    if (account == null) {
      print("Unable to Auth with Google");
      return null;
    }

    // Map the GoogleSignInAccount to a GoogleAuth object
    return GoogleAuth(
      id: account.id,
      displayName: account.displayName!,
      email: account.email,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
