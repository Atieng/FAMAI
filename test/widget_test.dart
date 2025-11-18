import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:famai/main.dart';

// A mock Firebase initialization is needed for tests.
// This is a simplified version for now.
import 'package:firebase_core/firebase_core.dart';
import 'firebase_mock.dart';

void main() {
  // Mock Firebase before running tests
    setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('App starts and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FamaiApp());

    // The AuthWrapper should initially show a loading indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Re-render after the stream has delivered its first value (null user).
    await tester.pumpAndSettle();

    // After loading, it should show the LoginScreen.
    expect(find.text('Login'), findsOneWidget);
  });
}

