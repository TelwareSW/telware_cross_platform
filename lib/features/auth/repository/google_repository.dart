import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:telware_cross_platform/core/models/app_error.dart';

part 'google_repository.g.dart';

@Riverpod(keepAlive: true)
GoogleRepository googleRepository(GoogleRepositoryRef ref) {
  return GoogleRepository(
    googleSignIn: GoogleSignIn(scopes: ['profile']),
  );
}

class GoogleRepository {
  final GoogleSignIn _googleSignIn;

  GoogleRepository({required GoogleSignIn googleSignIn})
      : _googleSignIn = googleSignIn;

  Future<Either<AppError, String>> logIn() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) {
        debugPrint('null user');
        return Left(AppError('Google sign in faild. Please, try again later.'));
      }

      final authenticator = await user.authentication;
      final idToken = authenticator.idToken;

      if (idToken == null) {
        return Left(AppError('Couldn\'t get the id token', code: 404));
      }
      return Right(idToken);
    } catch (e) {
      debugPrint(e.toString());
      return Left(AppError('Google sign in faild.\n Please, try again later.'));
    }
  }

  Future<AppError?> logOut() async {
    try {
      await _googleSignIn.signOut();
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return AppError('Log Out faild. Please,\n try again later.');
    }
  }
}
