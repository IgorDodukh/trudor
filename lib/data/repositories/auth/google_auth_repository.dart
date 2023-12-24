import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spoto/domain/auth/google_auth.dart';

class GoogleAuthRepository {
  final GoogleSignIn _googleSignIn;

  GoogleAuthRepository()
      : _googleSignIn = GoogleSignIn(clientId: dotenv.env["GOOGLE_CLIENT_ID"]);

  Future<GoogleAuth?> signIn() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    final UserCredential signInResult;

    if (_googleSignIn.currentUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await account!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth = FirebaseAuth.instance;
      signInResult = await auth.signInWithCredential(credential);
    } else {
      return null;
    }
    return GoogleAuth(
      id: signInResult.user!.uid,
      displayName: signInResult.user!.displayName!,
      email: signInResult.user!.email!,
      photoUrl: signInResult.user!.photoURL!,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
