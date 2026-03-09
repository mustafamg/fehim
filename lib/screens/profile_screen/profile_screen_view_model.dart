import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holy_quran/services/firestore_service.dart';
import 'package:holy_quran/utils/helper/shared_pref.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ProfileScreenViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  ProfileScreenViewModel(this._firestoreService);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userName = '';
  String get userName => _userName;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasInitialized = false;

  Future<void> init() async {
    if (_hasInitialized) return;
    _hasInitialized = true;
    final storedName =
        SharedPrefrencesHelper.getString(
          key: SharedPrefrencesHelper.userNameKey,
        ) ??
        '';
    final userId = SharedPrefrencesHelper.getString(
      key: SharedPrefrencesHelper.userIdKey,
    );

    if (userId == null || userId.isEmpty) {
      _userName = storedName;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final profile = await _firestoreService.getUserProfile(userId);
      final remoteName = (profile?['name'] as String?)?.trim();
      _userName = (remoteName?.isNotEmpty == true) ? remoteName! : storedName;
    } catch (_) {
      _userName = storedName;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SharedPrefrencesHelper.remove(key: SharedPrefrencesHelper.userIdKey);
    await SharedPrefrencesHelper.remove(
      key: SharedPrefrencesHelper.userNameKey,
    );
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
