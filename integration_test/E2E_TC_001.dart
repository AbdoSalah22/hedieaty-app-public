import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      testWidgets('End-to-End Test Case', (WidgetTester tester) async {
            // Ensure Firebase is initialized before the test starts
            await Firebase.initializeApp();

            // Launch the app
            await tester.pumpWidget(HedieatyApp());

            // Wait for animations or setup to complete
            await tester.pumpAndSettle();

            // Step 1: Log in
            await tester.enterText(find.byKey(const Key('email_field')), 'salah4@flutter.com');
            await tester.pump(Duration(seconds: 1));
            await tester.enterText(find.byKey(const Key('password_field')), 'salah1234');
            await tester.pump(Duration(seconds: 1));
            await tester.tap(find.byKey(const Key('login_button')));
            await tester.pumpAndSettle();

            // // Step 2: Click on the plus icon
            // await tester.tap(find.byKey(const Key('plus_icon_button')));
            // await tester.pumpAndSettle();
            //
            // // Step 3: Add a friend
            // await tester.enterText(find.byKey(const Key('add_friend_field')), 'salah1');
            // await tester.pumpAndSettle();
            // await tester.tap(find.byKey(const Key('add_friend_button')));
            // await tester.pumpAndSettle();

            // Step 4: Search for a friend
            await tester.tap(find.byKey(const Key('search_icon_button')));
            await tester.pumpAndSettle();
            await tester.enterText(find.byKey(const Key('search_friend_field')), 'salah1');
            await tester.pump(Duration(seconds: 3));
            await tester.tap(find.byKey(const Key('search_icon_button')));
            await tester.pumpAndSettle();

            // Step 5: Select the first friend in the ListView
            final firstFriend = find.descendant(
                  of: find.byType(ListView),
                  matching: find.byType(ListTile),
            ).last;
            await tester.tap(firstFriend);
            await tester.pumpAndSettle();

            // Step 6: Select the first event in the ListView
            final firstEvent = find.descendant(
                  of: find.byType(ListView),
                  matching: find.byType(ListTile),
            ).first;
            await tester.tap(firstEvent);
            await tester.pumpAndSettle();

            // // Step 7: Select the first gift in the GridView
            // final firstGift = find.descendant(
            //       of: find.byType(GridView),
            //       matching: find.byType(GestureDetector), // Replace GestureDetector with the appropriate widget type
            // ).first;
            // await tester.tap(firstGift);
            // await tester.pumpAndSettle();

            // Step 8: Tap the "Pledge Gift" button in the first card
            final pledgeButton = find.descendant(
                  of: find.byType(Card).first,
                  matching: find.byKey(const ValueKey('pledge_gift_button')),
            );
            await tester.tap(pledgeButton);
            await tester.pumpAndSettle();

            await tester.tap(find.byKey(const Key('confirm_button')));
            await tester.pump(Duration(seconds: 3));

            // Step 9: Navigate back twice
            await tester.pageBack();
            await tester.pump(Duration(seconds: 3));
            await tester.tap(find.byKey(const Key('arrow_back_icon_button')));
            await tester.pump(Duration(seconds: 3));

            // Step 10: Go to Profile and check pledged gifts
            await tester.tap(find.byKey(const Key('profile_icon_button')));
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const Key('my_pledged_gifts_button')));
            await tester.pumpAndSettle(Duration(seconds: 3)); // Wait for loading

            // Step 11: Navigate back to main
            await tester.pageBack();
            await tester.pumpAndSettle();

            // Step 12: Add an event
            await tester.tap(find.byKey(const Key('events_icon_button')));
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const Key('add_event_button')));
            await tester.pumpAndSettle();
            await tester.enterText(find.byKey(const Key('event_name_field')), 'Test Event');
            await tester.pump(Duration(seconds: 1));
            await tester.enterText(find.byKey(const Key('event_description_field')), 'Test Description');
            await tester.pump(Duration(seconds: 1));
            await tester.enterText(find.byKey(const Key('event_location_field')), 'Test Location');
            await tester.pump(Duration(seconds: 1));
            await tester.tap(find.byKey(const Key('choose_date_button')));
            await tester.pumpAndSettle();
            await tester.tap(find.text('OK')); // Confirm in the pop-up calendar
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const Key('cancel_event_button')));
            await tester.pump(Duration(seconds: 1));

            // Step 13: Select the first event in the ListView
            final myFirstEvent = find.descendant(
                  of: find.byType(ListView),
                  matching: find.byType(ListTile),
            ).first;
            await tester.tap(myFirstEvent);
            await tester.pump(Duration(seconds: 5));
      });
}
