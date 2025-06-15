import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/google_oauth_config.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Google Sign In
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: GoogleOAuthConfig.clientId,
        scopes: ['email'],
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      
      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken!,
        accessToken: accessToken,
      );
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }
  
  // Apple Sign In
  Future<AuthResponse?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw 'Unable to get identity token from Apple Sign In';
      }
      
      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );
    } catch (e) {
      print('Error signing in with Apple: $e');
      return null;
    }
  }
  
  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    
    // Google Sign Out
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }
  
  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  // Check if user is signed in
  bool get isSignedIn => currentUser != null;
}