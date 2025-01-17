// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:Runbhumi/components/googleOauth.dart';
import 'package:Runbhumi/widget/inputBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(MyApp());

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }

void main() {
  MaterialApp app = MaterialApp(
    home: Scaffold(
      body: InputBox(hintText: "inp"),
    ),
  );
  testWidgets('input box UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(app);

    expect(find.byType(TextFormField), findsNWidgets(1));
  });
  // testWidgets('GoogleOauthBig UI Test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(app);

  //   expect(find.byType(Text), findsNWidgets(1));
  // });
}
