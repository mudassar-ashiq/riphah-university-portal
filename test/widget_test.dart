import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:university_portal/main.dart';
import 'package:university_portal/models/portal_models.dart';
import 'package:university_portal/services/auth_service.dart';

import 'fakes.dart';

/// Pumps the app with fake services on a tall phone-like surface so
/// forms fit on screen without scrolling.
Future<void> pumpApp(
  WidgetTester tester, {
  FakeAuthService? auth,
  FakePortalRepository? repo,
}) async {
  tester.view.physicalSize = const Size(900, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UniversityPortalApp(
      authService: auth ?? FakeAuthService(),
      repository: repo ?? FakePortalRepository(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Signs in through the login screen with the fake auth service.
Future<void> logIn(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextFormField).at(0),
    'f24-bsse-0077@students.riphah.edu.pk',
  );
  await tester.enterText(find.byType(TextFormField).at(1), 'portal123');
  await tester.tap(find.text('Log In'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

const testProfile = UserProfile(
  uid: 'test-uid',
  name: 'Mudassar Ashiq',
  roll: 'F24-BSSE-0077',
  program: 'BSSE',
  semester: 5,
  section: 'A',
  email: 'f24-bsse-0077@students.riphah.edu.pk',
);

void main() {
  group('percentage computation', () {
    test('result percentage', () {
      const r = ResultEntry(subject: 'Maths', totalMarks: 50, obtainedMarks: 45);
      expect(r.percentage, 90);
      expect(percentOf(17, 20), 85);
    });

    test('percentage is zero when the total is zero', () {
      const r = ResultEntry(subject: 'X', totalMarks: 0, obtainedMarks: 0);
      expect(r.percentage, 0);
      const a = AttendanceEntry(course: 'OS', held: 0, attended: 0);
      expect(a.percentage, 0);
    });

    test('attendance percentage', () {
      const a = AttendanceEntry(course: 'OS', held: 20, attended: 17);
      expect(a.percentage, 85);
    });
  });

  group('models', () {
    test('result entry map round trip', () {
      const r = ResultEntry(
        id: 'r1',
        subject: 'Operating Systems',
        totalMarks: 100,
        obtainedMarks: 82,
      );
      final back = ResultEntry.fromMap('r1', r.toMap());
      expect(back.subject, 'Operating Systems');
      expect(back.totalMarks, 100);
      expect(back.obtainedMarks, 82);
      expect(back.percentage, 82);
    });

    test('fee entry map round trip and paid copy', () {
      final fee = FeeEntry(
        id: 'f1',
        title: 'Semester fee',
        amount: 68500,
        dueDate: DateTime(2026, 11, 20),
      );
      final back = FeeEntry.fromMap('f1', {
        ...fee.toMap(),
        'dueDate': fee.dueDate.toIso8601String(),
      });
      expect(back.title, 'Semester fee');
      expect(back.amount, 68500);
      expect(back.dueDate, DateTime(2026, 11, 20));
      expect(back.paid, isFalse);
      expect(fee.copyWith(paid: true).paid, isTrue);
    });

    test('profile map round trip keeps role', () {
      final back = UserProfile.fromMap('u1', testProfile.toMap());
      expect(back.name, 'Mudassar Ashiq');
      expect(back.semester, 5);
      expect(back.role, 'student');
      expect(back.isAdmin, isFalse);
    });
  });

  group('timetable match logic', () {
    test('BSSE section A semester 5 matches', () {
      expect(
        matchesBsseASemester5(program: 'BSSE', section: 'A', semester: 5),
        isTrue,
      );
      expect(
        matchesBsseASemester5(
          program: 'BS Software Engineering',
          section: 'BSSE-A',
          semester: 5,
        ),
        isTrue,
      );
    });

    test('other sections, semesters and programs do not match', () {
      expect(
        matchesBsseASemester5(program: 'BSSE', section: 'B', semester: 5),
        isFalse,
      );
      expect(
        matchesBsseASemester5(program: 'BSSE', section: 'A', semester: 4),
        isFalse,
      );
      expect(
        matchesBsseASemester5(program: 'BSCS', section: 'A', semester: 5),
        isFalse,
      );
    });
  });

  group('friendly auth errors', () {
    test('known codes map to friendly messages', () {
      expect(
        friendlyAuthMessage('user-not-found'),
        contains('No account found'),
      );
      expect(
        friendlyAuthMessage('invalid-credential'),
        contains('Incorrect email or password'),
      );
      expect(
        friendlyAuthMessage('email-already-in-use'),
        contains('already exists'),
      );
      expect(
        friendlyAuthMessage('network-request-failed'),
        contains('Network error'),
      );
      expect(friendlyAuthMessage('something-else'), contains('went wrong'));
      expect(friendlyAuthMessage(null), contains('went wrong'));
    });
  });

  group('app flows (fake services)', () {
    testWidgets('app opens on the login screen when signed out', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.text('Riphah University Portal'), findsOneWidget);
      expect(find.text('Log In'), findsWidgets);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('University email'), findsOneWidget);
    });

    testWidgets('login rejects an invalid email', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'portal123');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('login failure shows the friendly error', (tester) async {
      final auth = FakeAuthService()..failSignIn = true;
      await pumpApp(tester, auth: auth);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'student@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'portal123');
      await tester.tap(find.text('Log In'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.text('Incorrect email or password. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('sign up requires the student details', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Sign Up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your roll number'), findsOneWidget);
      expect(find.text('Please enter your program'), findsOneWidget);
      expect(find.text('Please enter your section'), findsOneWidget);
    });

    testWidgets('sign up creates the profile and opens the portal', (
      tester,
    ) async {
      final auth = FakeAuthService();
      final repo = FakePortalRepository();
      await pumpApp(tester, auth: auth, repo: repo);

      await tester.tap(find.text('Sign Up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Sign-up field order: name, roll, program, section, email, password.
      await tester.enterText(find.byType(TextFormField).at(0), 'Mudassar Ashiq');
      await tester.enterText(find.byType(TextFormField).at(1), 'F24-BSSE-0077');
      await tester.enterText(find.byType(TextFormField).at(2), 'BSSE');
      await tester.enterText(find.byType(TextFormField).at(3), 'A');
      await tester.enterText(
        find.byType(TextFormField).at(4),
        'f24-bsse-0077@students.riphah.edu.pk',
      );
      await tester.enterText(find.byType(TextFormField).at(5), 'portal123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      // Profile was written to the repository with the student role.
      final profile = repo.profiles['new-uid'];
      expect(profile, isNotNull);
      expect(profile!.name, 'Mudassar Ashiq');
      expect(profile.roll, 'F24-BSSE-0077');
      expect(profile.semester, 5);
      expect(profile.role, 'student');
      expect(auth.lastSignUpEmail, 'f24-bsse-0077@students.riphah.edu.pk');

      // Dashboard shows the signed-in student, not demo data.
      expect(find.text('Mudassar Ashiq'), findsOneWidget);
      expect(find.text('Quick access'), findsOneWidget);
      expect(find.text('Next class'), findsOneWidget);
    });

    testWidgets('dashboard and timetable work for a BSSE-A student', (
      tester,
    ) async {
      final auth = FakeAuthService()..signInAs('test-uid');
      final repo = FakePortalRepository()
        ..profiles['test-uid'] = testProfile;
      await pumpApp(tester, auth: auth, repo: repo);
      await logInNotNeeded(tester);

      expect(find.text('Mudassar Ashiq'), findsOneWidget);

      await tester.tap(find.text('Timetable'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Game Programming (Lab)'), findsOneWidget);
      expect(
        find.text('Parallel & Distributed Computing (Lab)'),
        findsOneWidget,
      );
    });

    testWidgets('non-matching profile sees the timetable empty state', (
      tester,
    ) async {
      final auth = FakeAuthService()..signInAs('test-uid');
      final repo = FakePortalRepository()
        ..profiles['test-uid'] = const UserProfile(
          uid: 'test-uid',
          name: 'Ayesha Khan',
          roll: 'F24-BSCS-0011',
          program: 'BSCS',
          semester: 3,
          section: 'B',
          email: 'ayesha@example.com',
        );
      await pumpApp(tester, auth: auth, repo: repo);

      await tester.tap(find.text('Courses'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Your class timetable has not been added yet.'),
        findsOneWidget,
      );
    });

    testWidgets('adding a result shows it with its percentage', (
      tester,
    ) async {
      final auth = FakeAuthService()..signInAs('test-uid');
      final repo = FakePortalRepository()
        ..profiles['test-uid'] = testProfile;
      await pumpApp(tester, auth: auth, repo: repo);

      await tester.tap(find.text('Results'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('No results yet'), findsOneWidget);

      // Form order: subject, obtained, total.
      await tester.enterText(find.byType(TextField).at(0), 'Operating Systems');
      await tester.enterText(find.byType(TextField).at(1), '45');
      await tester.enterText(find.byType(TextField).at(2), '50');
      await tester.tap(find.text('Add result'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Operating Systems'), findsOneWidget);
      expect(find.text('90.0%'), findsOneWidget);
      expect(repo.resultsByUid['test-uid']!.single.percentage, 90);
    });

    testWidgets('adding a fee updates the outstanding balance', (
      tester,
    ) async {
      final auth = FakeAuthService()..signInAs('test-uid');
      final repo = FakePortalRepository()
        ..profiles['test-uid'] = testProfile;
      await pumpApp(tester, auth: auth, repo: repo);

      await tester.tap(find.text('More'));
      await tester.pump();
      await tester.tap(find.text('Fees & Challans'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Outstanding balance'), findsOneWidget);
      expect(find.text('Rs 0'), findsWidgets);

      await tester.enterText(find.byType(TextField).at(0), 'Semester fee');
      await tester.enterText(find.byType(TextField).at(1), '68500');
      await tester.tap(find.text('Add fee'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Semester fee'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Rs 68,500'), findsWidgets);
    });

    testWidgets('log out returns to the login screen', (tester) async {
      final auth = FakeAuthService();
      final repo = FakePortalRepository()
        ..profiles['test-uid'] = testProfile;
      await pumpApp(tester, auth: auth, repo: repo);
      await logIn(tester);

      expect(find.text('Mudassar Ashiq'), findsOneWidget);

      await tester.tap(find.text('More'));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Log Out'), 120);
      await tester.pump();
      await tester.tap(find.text('Log Out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.text('Riphah University Portal'), findsOneWidget);
      expect(find.text('University email'), findsOneWidget);
    });
  });
}

/// The app is already signed in (fake auth preset), so no login form
/// interaction is needed — this just lets pending streams deliver.
Future<void> logInNotNeeded(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}
