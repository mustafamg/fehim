import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/services/firestore_service.dart';
import 'package:holy_quran/utils/helper/shared_pref.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

@Injectable()
class LoginScreenViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAppleLoading = false;
  bool get isAppleLoading => _isAppleLoading;

  bool _isFirebaseSupported = true;
  bool get isFirebaseSupported => _isFirebaseSupported;

  String? _unsupportedMessage;
  String? get unsupportedMessage => _unsupportedMessage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    await _evaluateFirebaseSupport();
  }

  Future<bool> loginWithGoogle() async {
    if (!_isFirebaseSupported) {
      _errorMessage =
          _unsupportedMessage ?? S.current.loginUnsupportedDeviceMessage;
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate(scopeHint: ['email', 'profile']);

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizationForScopes(['email', 'profile']);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;
        final userId = user.uid;
        final displayName =
            user.displayName ?? user.email ?? S.current.profileDefaultName;
        await SharedPrefrencesHelper.saveString(
          key: SharedPrefrencesHelper.userIdKey,
          value: userId,
        );
        await SharedPrefrencesHelper.saveString(
          key: SharedPrefrencesHelper.userNameKey,
          value: displayName,
        );

        await _firestoreService.saveUserProfile(
          userId: userId,
          name: displayName,
          email: user.email ?? '',
          photoUrl: user.photoURL,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = S.current.loginFailedAuth;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        // User canceled the sign in
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _errorMessage = S.current.loginGenericError(e.code.name);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = S.current.loginGenericError('$e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    _isAppleLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user != null) {
        final hasName =
            (appleCredential.givenName?.isNotEmpty ?? false) ||
            (appleCredential.familyName?.isNotEmpty ?? false);
        final displayName = hasName
            ? '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                  .trim()
            : user.displayName ?? user.email ?? S.current.profileDefaultName;

        final email = user.email ?? appleCredential.email ?? '';

        await SharedPrefrencesHelper.saveString(
          key: SharedPrefrencesHelper.userIdKey,
          value: user.uid,
        );
        await SharedPrefrencesHelper.saveString(
          key: SharedPrefrencesHelper.userNameKey,
          value: displayName,
        );

        await _firestoreService.saveUserProfile(
          userId: user.uid,
          name: displayName,
          email: email,
          photoUrl: user.photoURL,
        );

        _isAppleLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = S.current.loginFailedAuth;
        _isAppleLoading = false;
        notifyListeners();
        return false;
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        _isAppleLoading = false;
        notifyListeners();
        return false;
      }
      _errorMessage = S.current.loginGenericError(e.code.name);
      _isAppleLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = S.current.loginGenericError('$e');
      _isAppleLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _evaluateFirebaseSupport() async {
    if (!Platform.isAndroid) {
      _isFirebaseSupported = true;
      _unsupportedMessage = null;
      notifyListeners();
      return;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final manufacturer = androidInfo.manufacturer.toLowerCase();
      final brand = androidInfo.brand.toLowerCase();
      final model = androidInfo.model.toLowerCase();
      final isHuawei =
          manufacturer.contains('huawei') ||
          brand.contains('huawei') ||
          model.contains('huawei');

      _isFirebaseSupported = !isHuawei;
      _unsupportedMessage = isHuawei
          ? S.current.loginUnsupportedDeviceMessage
          : null;
      notifyListeners();
    } catch (_) {
      _isFirebaseSupported = true;
      _unsupportedMessage = null;
      notifyListeners();
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
