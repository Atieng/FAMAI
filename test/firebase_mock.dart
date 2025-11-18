import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function();

// This is a generic mock for Firebase Core.
// It's used to prevent tests from crashing when they try to initialize Firebase.
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Firebase Core
  FirebaseCorePlatform.instance = FakeFirebaseCore();
}

class FakeFirebaseCore extends Fake implements FirebaseCorePlatform {
  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return FakeFirebaseApp(name, options);
  }

  @override
  Future<FirebaseAppPlatform> app([String name = defaultFirebaseAppName]) async {
    return FakeFirebaseApp(name, null);
  }
}

class FakeFirebaseApp extends Fake implements FirebaseAppPlatform {
  FakeFirebaseApp(String? name, FirebaseOptions? options) : 
    _name = name ?? defaultFirebaseAppName,
    _options = options ?? const FirebaseOptions(
      apiKey: 'fake-api-key',
      appId: 'fake-app-id',
      messagingSenderId: 'fake-sender-id',
      projectId: 'fake-project-id',
    );

  final String _name;
  final FirebaseOptions _options;

  @override
  String get name => _name;

  @override
  FirebaseOptions get options => _options;

  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}

  @override
  Future<void> delete() async {}
}
