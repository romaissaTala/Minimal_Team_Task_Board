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
  
  // Add these new methods
  Future<void> sendMagicLink({required String email});
  Future<UserModel> verifyMagicLink({
    required String email,
    required String token,
  });
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

      // Get or create profile
      final userModel = await _getOrCreateUserProfile(response.user!, email);
      return userModel;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendMagicLink({required String email}) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'com.taskboard.app://login-callback',
      );
    } catch (e) {
      throw Exception('Failed to send magic link: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> verifyMagicLink({
    required String email,
    required String token,
  }) async {
    try {
      // Verify the OTP token
      final response = await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.magiclink,
      );
      
      if (response.user == null) throw Exception('Verification failed');
      
      // Get or create profile
      final userModel = await _getOrCreateUserProfile(response.user!, email);
      return userModel;
    } catch (e) {
      throw Exception('Failed to verify magic link: ${e.toString()}');
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
        data: {'username': username},
        emailRedirectTo: 'com.taskboard.app://login-callback',
      );

      if (response.user == null) throw Exception('Registration failed');
      
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

  // Helper method to get or create user profile
  Future<UserModel> _getOrCreateUserProfile(User user, String email) async {
    UserModel? userModel;
    int retries = 0;
    
    while (retries < 5) {
      try {
        final profile = await _client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        
        if (profile != null) {
          // Update status to online
          await _client
              .from('profiles')
              .update({'status': 'online'})
              .eq('id', user.id);
          
          userModel = UserModel.fromJson(profile, email);
          break;
        }
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 500));
      }
      retries++;
    }
    
    if (userModel == null) {
      // Create profile if it doesn't exist
      userModel = UserModel(
        id: user.id,
        email: email,
        username: email.split('@').first,
      );
    }
    
    return userModel;
  }
}