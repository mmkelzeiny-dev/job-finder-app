import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

// --- GLOBAL SETUP ---

final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

final storage = FlutterSecureStorage();

// CRITICAL CHANGE 1: Use 'late final' because 'dio' must be initialized in a function.
late final Dio dio;

// --- DIO INTERCEPTOR CLASS ---

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  AuthInterceptor(this.storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('🌐 Interceptor checking path: ${options.path}');

    if (!options.path.contains('/auth/google')) {
      final token = await storage.read(key: 'jwt_token');

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        print('✅ Attached JWT to: ${options.path}');
      } else {
        // THIS IS THE CRITICAL LOG WE NEED
        print('⚠️ INTERCEPTOR: No token found in storage for ${options.path}');
      }
    }
    handler.next(options);
  }
}

// --- AUTH SERVICE CLASS ---

class AuthService {
  // CRITICAL FUNCTION: Must be called once on app startup (e.g., in main.dart)
  static void initializeDio() {
    // 2. Initialize the late final dio instance
    dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.1.58:8000",
        // Set content type for POST requests
        contentType: "application/json",
      ),
    );
    // 3. Apply the interceptor immediately after initialization
    dio.interceptors.add(AuthInterceptor(storage));
    print("Dio initialized with JWT Interceptor.");
  }

  // Call this with a specific idToken
  static Future<bool> signInWithGoogleCustomToken(String idToken) async {
    final storage = new FlutterSecureStorage();
    // await storage
    //     .deleteAll(); // Clears ALL keys. Be careful if you have other keys.
    try {
      final response = await dio.post("/auth/google", data: {"token": idToken});
      print("Backend Response: ${response.data}");

      final jwt = response.data["access_token"] as String;
      final userId = response.data["user_id"] as String;

      await storage.write(key: "jwt_token", value: jwt);
      await storage.write(key: "user_id", value: userId);
      print("JWT from backend saved: $jwt");
      return true;
    } catch (e) {
      print("Backend login failed: $e");
      return false;
    }
  }

  // Call this when user presses “Sign in with Google”
  static Future<bool> signInWithGoogle() async {
    try {
      final account = await googleSignIn.signIn();
      if (account == null) return false; // user cancelled

      final auth = await account.authentication;
      if (auth.idToken == null) return false;

      // Note: We use the Firebase ID Token (auth.idToken) to get the custom JWT
      final response = await dio.post(
        "/auth/google",
        data: {"token": auth.idToken},
      );

      final jwt = response.data["access_token"] as String;
      final userId = response.data["user_id"] as String;
      print("JWT from backend: $jwt");

      await storage.write(key: "jwt_token", value: jwt);
      await storage.write(key: "user_id", value: userId);

      print("Login successful.. JWT saved");
      return true;
    } catch (e) {
      print("Google Sign-In failed: $e");
      return false;
    }
  }

  static Future<String?> getJwtToken() async {
    return await storage.read(key: "jwt_token");
  }

  static Future<String?> getUserId() async {
    return await storage.read(key: "user_id");
  }

  static Future<void> signOut() async {
    await googleSignIn.signOut();
    await storage.deleteAll();
    print("User signed out and tokens cleared.");
  }
}
