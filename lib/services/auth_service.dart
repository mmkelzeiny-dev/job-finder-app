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
    if (!options.path.contains('/auth/google')) {
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {}
    }
    handler.next(options);
  }
}

// --- AUTH SERVICE CLASS ---

class AuthService {
  static void initializeDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.1.58:8000",
        // Set content type for POST requests
        contentType: "application/json",
      ),
    );
    dio.interceptors.add(AuthInterceptor(storage));
  }

  static Future<bool> signInWithGoogleCustomToken(String idToken) async {
    final storage = new FlutterSecureStorage();
    try {
      final response = await dio.post("/auth/google", data: {"token": idToken});

      final jwt = response.data["access_token"] as String;
      final userId = response.data["user_id"] as String;

      await storage.write(key: "jwt_token", value: jwt);
      await storage.write(key: "user_id", value: userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> signInWithGoogle() async {
    try {
      final account = await googleSignIn.signIn();
      if (account == null) return false; // user cancelled

      final auth = await account.authentication;
      if (auth.idToken == null) return false;

      final response = await dio.post(
        "/auth/google",
        data: {"token": auth.idToken},
      );

      final jwt = response.data["access_token"] as String;
      final userId = response.data["user_id"] as String;

      await storage.write(key: "jwt_token", value: jwt);
      await storage.write(key: "user_id", value: userId);

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
