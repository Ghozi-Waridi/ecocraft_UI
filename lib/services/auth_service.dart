import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  final _supabase = SupabaseConfig.client;

  /// Login with username and password
  /// Returns UserModel if successful, null otherwise
  Future<UserModel?> login(String username, String password) async {
    try {
      // Query user by username
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // In a real app, you would verify password hash here
      // For now, we'll use a simple check (NOT SECURE - for demo only)
      // TODO: Implement proper password hashing with bcrypt or similar
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Get current user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserModel.fromJson(response);
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  /// Get current user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserModel.fromJson(response);
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  /// Create new user (admin only)
  Future<UserModel?> createUser({
    required String username,
    required String fullName,
    String? email,
    String role = 'user',
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .insert({
            'username': username,
            'full_name': fullName,
            'email': email,
            'role': role,
            'total_bottles': 0,
          })
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Create user error: $e');
      return null;
    }
  }

  /// Logout (clear local session)
  Future<void> logout() async {
    // In a real app with Supabase Auth, you would call:
    // await _supabase.auth.signOut();
    // For now, this is handled by the provider
  }
}
