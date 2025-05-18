import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password, String name, String department, String semester) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user info to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'department': department,
        'semester': semester,
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore, if not create a new entry
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      notifyListeners();
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
    }
    return null;
  }
}