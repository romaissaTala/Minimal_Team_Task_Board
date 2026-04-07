// auth_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
  });
  Future<void> logout();
  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;
  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) throw Exception('Login failed');

      // Try to get profile, wait a moment if it doesn't exist yet
      UserModel? userModel;
      int retries = 0;
      while (retries < 5) {
        try {
          final profile = await _client
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle(); // Use maybeSingle to avoid exception
          
          if (profile != null) {
            // Update status to online
            await _client
                .from('profiles')
                .update({'status': 'online'})
                .eq('id', response.user!.id);
            
            userModel = UserModel.fromJson(profile, email);
            break;
          }
        } catch (e) {
          // Profile might not be created yet, wait and retry
          await Future.delayed(Duration(milliseconds: 500));
        }
        retries++;
      }
      
      if (userModel == null) {
        // Fallback: create minimal user model without profile
        userModel = UserModel(
          id: response.user!.id,
          email: email,
          username: email.split('@').first,
        );
      }
      
      return userModel;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'avatar_url': null,
        },
        emailRedirectTo: 'com.taskboard.app://login-callback',
      );

      if (response.user == null) {
        throw Exception('Registration failed');
      }

      // Wait a bit for the trigger to create the profile
      await Future.delayed(Duration(seconds: 1));
      
      // Try to verify profile was created
      int retries = 0;
      while (retries < 3) {
        try {
          final profile = await _client
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();
          
          if (profile != null) {
            break;
          }
        } catch (e) {
          // Profile not ready yet
          await Future.delayed(Duration(milliseconds: 500));
        }
        retries++;
      }

      return UserModel(
        id: response.user!.id,
        email: email,
        username: username,
      );
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId != null) {
        await _client
            .from('profiles')
            .update({'status': 'offline'})
            .eq('id', userId);
      }
      await _client.auth.signOut();
    } catch (e) {
      // Even if profile update fails, still try to sign out
      await _client.auth.signOut();
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: user.userMetadata?['username'] ?? user.email?.split('@').first ?? '',
    );
  }
}