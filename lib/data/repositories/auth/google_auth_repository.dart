import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trudor/domain/auth/google_auth.dart';

class GoogleAuthRepository {
  final GoogleSignIn _googleSignIn;

  GoogleAuthRepository() : _googleSignIn = GoogleSignIn(clientId: dotenv.env["GOOGLE_CLIENT_ID"]);

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
