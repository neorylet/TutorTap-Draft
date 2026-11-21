import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> initializeGoogleSignIn() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  Future<UserCredential?> signInWithGoogle() async {
    await initializeGoogleSignIn();
    final GoogleSignInAccount account = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication authentication = account.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (_googleInitialized) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  Future<AppUser?> readUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .get();
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return AppUser.fromMap(<String, dynamic>{...data, 'uid': uid});
  }

  Stream<AppUser?> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      final Map<String, dynamic>? data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return AppUser.fromMap(<String, dynamic>{...data, 'uid': uid});
    });
  }

  Future<void> writeUser(AppUser user) {
    return _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUserRole(String uid, UserRole role) {
    return _firestore.collection('users').doc(uid).set(<String, dynamic>{
      'role': role.value,
    }, SetOptions(merge: true));
  }

  Future<AppUser> ensureUserDoc({
    required User user,
    String? displayName,
  }) async {
    final AppUser? existing = await readUser(user.uid);
    if (existing != null) return existing;

    final AppUser profile = AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName:
          displayName ??
          user.displayName ??
          user.email?.split('@').first ??
          'TutorTap user',
      role: null,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
    await writeUser(profile);
    return profile;
  }
}
