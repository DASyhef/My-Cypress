import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _webClientId = String.fromEnvironment(
    'WEB_CLIENT_ID',
    defaultValue:
        '463762864980-aokfcle4s3nolsmmbiiieve0hcam0ccr.apps.googleusercontent.com',
  );

  bool _isGoogleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await GoogleSignIn.instance.initialize(
        clientId: _webClientId,
      );
      _isGoogleSignInInitialized = true;
    }
  }

  Stream<User?> get userState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> _handleUserRegistration(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'title': '',
        'lastName': '',
        'birthName': '',
        'firstName': '',
        'nickname': '',
        'birthDate': '',
        'country': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      try {
        await _handleUserRegistration(credential.user!);
      } catch (e) {
        await _auth.signOut();
        rethrow;
      }
    }
    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      try {
        final userRef = _firestore.collection('users').doc(credential.user!.uid);
        final doc = await userRef.get();

        if (!doc.exists) {
          await _auth.signOut();
          throw FirebaseAuthException(
            code: 'user-not-registered',
            message: 'Aucun compte associé à cet email. Veuillez d\'abord vous inscrire.',
          );
        }
      } catch (e) {
        await _auth.signOut();
        if (e is FirebaseAuthException) rethrow;
        throw FirebaseAuthException(
          code: 'firestore-check-failed',
          message: 'Erreur lors de la vérification du compte : $e',
        );
      }
    }

    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<UserCredential?> signUpWithGoogle() async {
    UserCredential credential;

    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      credential = await _auth.signInWithPopup(googleProvider);
    } else {
      await _ensureGoogleSignInInitialized();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final scopes = ['email', 'profile'];
      final authorization =
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final OAuthCredential oauthCredential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      credential = await _auth.signInWithCredential(oauthCredential);
    }

    if (credential.user != null) {
      try {
        await _handleUserRegistration(credential.user!);
      } catch (e) {
        await _auth.signOut();
        if (!kIsWeb) {
          await GoogleSignIn.instance.signOut();
        }
        rethrow;
      }
    }

    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    UserCredential credential;

    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      credential = await _auth.signInWithPopup(googleProvider);
    } else {
      await _ensureGoogleSignInInitialized();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final scopes = ['email', 'profile'];
      final authorization =
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final OAuthCredential oauthCredential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      credential = await _auth.signInWithCredential(oauthCredential);
    }

    if (credential.user != null) {
      try {
        final userRef = _firestore.collection('users').doc(credential.user!.uid);
        final doc = await userRef.get();

        if (!doc.exists) {
          await _auth.signOut();
          if (!kIsWeb) {
            await GoogleSignIn.instance.signOut();
          }
          throw FirebaseAuthException(
            code: 'user-not-registered',
            message: 'Aucun compte enregistré avec ce Google. Veuillez d\'abord vous inscrire.',
          );
        }
      } catch (e) {
        await _auth.signOut();
        if (!kIsWeb) {
          await GoogleSignIn.instance.signOut();
        }
        if (e is FirebaseAuthException) rethrow;
        throw FirebaseAuthException(
          code: 'firestore-check-failed',
          message: 'Erreur lors de la vérification du compte : $e',
        );
      }
    }

    return credential;
  }

  Future<UserCredential> signUpWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final OAuthProvider provider = OAuthProvider('apple.com');
    final AuthCredential credential = provider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      try {
        await _handleUserRegistration(userCredential.user!);
      } catch (e) {
        await _auth.signOut();
        rethrow;
      }
    }

    return userCredential;
  }

  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final OAuthProvider provider = OAuthProvider('apple.com');
    final AuthCredential credential = provider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      try {
        final userRef = _firestore.collection('users').doc(userCredential.user!.uid);
        final doc = await userRef.get();

        if (!doc.exists) {
          await _auth.signOut();
          throw FirebaseAuthException(
            code: 'user-not-registered',
            message: 'Aucun compte enregistré avec Apple. Veuillez d\'abord vous inscrire.',
          );
        }
      } catch (e) {
        await _auth.signOut();
        if (e is FirebaseAuthException) rethrow;
        throw FirebaseAuthException(
          code: 'firestore-check-failed',
          message: 'Erreur lors de la vérification du compte : $e',
        );
      }
    }

    return userCredential;
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signUpWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      try {
        await _handleUserRegistration(userCredential.user!);
      } catch (e) {
        await _auth.signOut();
        rethrow;
      }
    }

    return userCredential;
  }

  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      try {
        final userRef = _firestore.collection('users').doc(userCredential.user!.uid);
        final doc = await userRef.get();

        if (!doc.exists) {
          await _auth.signOut();
          throw FirebaseAuthException(
            code: 'user-not-registered',
            message: 'Aucun compte enregistré avec ce numéro. Veuillez d\'abord vous inscrire.',
          );
        }
      } catch (e) {
        await _auth.signOut();
        if (e is FirebaseAuthException) rethrow;
        throw FirebaseAuthException(
          code: 'firestore-check-failed',
          message: 'Erreur lors de la vérification du compte : $e',
        );
      }
    }

    return userCredential;
  }

  Future<void> signOut() async {
    if (!kIsWeb && _isGoogleSignInInitialized) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }
}