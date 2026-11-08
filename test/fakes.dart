import 'dart:async';

import 'package:university_portal/models/portal_models.dart';
import 'package:university_portal/services/auth_service.dart';
import 'package:university_portal/services/portal_repository.dart';

/// In-memory AuthService: no Firebase involved.
class FakeAuthService implements AuthService {
  final _changes = StreamController<String?>.broadcast();
  String? _uid;

  /// When true, signIn throws the invalid-credential friendly error.
  bool failSignIn = false;
  String? lastSignUpEmail;

  @override
  Stream<String?> get authStateChanges async* {
    yield _uid;
    yield* _changes.stream;
  }

  @override
  String? get currentUid => _uid;

  void _setUid(String? uid) {
    _uid = uid;
    _changes.add(uid);
  }

  /// Test helper: start (or switch) signed in as [uid].
  void signInAs(String uid) => _setUid(uid);

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    if (failSignIn) {
      throw AuthException(friendlyAuthMessage('invalid-credential'));
    }
    _setUid('test-uid');
    return 'test-uid';
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    lastSignUpEmail = email;
    _setUid('new-uid');
    return 'new-uid';
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async => _setUid(null);
}

/// In-memory PortalRepository backed by plain maps/lists.
class FakePortalRepository implements PortalRepository {
  final Map<String, UserProfile> profiles = {};
  final Map<String, List<ResultEntry>> resultsByUid = {};
  final Map<String, List<FeeEntry>> feesByUid = {};
  final Map<String, List<AttendanceEntry>> attendanceByUid = {};
  final List<PortalNotice> noticeList = [];

  final _changes = StreamController<void>.broadcast();
  int _nextId = 0;

  String _id() => 'doc-${++_nextId}';
  void _emit() => _changes.add(null);

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  @override
  Stream<UserProfile?> profileStream(String uid) =>
      _watch(() => profiles[uid]);

  @override
  Future<void> createProfile(UserProfile profile) async {
    profiles[profile.uid] = profile;
    _emit();
  }

  @override
  Stream<List<ResultEntry>> resultsStream(String uid) =>
      _watch(() => List.of(resultsByUid[uid] ?? const []));

  @override
  Future<void> addResult(String uid, ResultEntry entry) async {
    final list = resultsByUid.putIfAbsent(uid, () => []);
    list.add(
      ResultEntry(
        id: _id(),
        subject: entry.subject,
        totalMarks: entry.totalMarks,
        obtainedMarks: entry.obtainedMarks,
      ),
    );
    _emit();
  }

  @override
  Future<void> deleteResult(String uid, String id) async {
    resultsByUid[uid]?.removeWhere((e) => e.id == id);
    _emit();
  }

  @override
  Stream<List<FeeEntry>> feesStream(String uid) =>
      _watch(() => List.of(feesByUid[uid] ?? const []));

  @override
  Future<void> addFee(String uid, FeeEntry entry) async {
    final list = feesByUid.putIfAbsent(uid, () => []);
    list.add(
      FeeEntry(
        id: _id(),
        title: entry.title,
        amount: entry.amount,
        dueDate: entry.dueDate,
        paid: entry.paid,
      ),
    );
    _emit();
  }

  @override
  Future<void> setFeePaid(String uid, String id, bool paid) async {
    final list = feesByUid[uid];
    if (list == null) return;
    final i = list.indexWhere((e) => e.id == id);
    if (i >= 0) list[i] = list[i].copyWith(paid: paid);
    _emit();
  }

  @override
  Future<void> deleteFee(String uid, String id) async {
    feesByUid[uid]?.removeWhere((e) => e.id == id);
    _emit();
  }

  @override
  Stream<List<AttendanceEntry>> attendanceStream(String uid) =>
      _watch(() => List.of(attendanceByUid[uid] ?? const []));

  @override
  Future<void> upsertAttendance(String uid, AttendanceEntry entry) async {
    final list = attendanceByUid.putIfAbsent(uid, () => []);
    final i = list.indexWhere((e) => e.course == entry.course);
    final stored = AttendanceEntry(
      id: entry.id ?? (i >= 0 ? list[i].id : _id()),
      course: entry.course,
      held: entry.held,
      attended: entry.attended,
    );
    if (i >= 0) {
      list[i] = stored;
    } else {
      list.add(stored);
    }
    _emit();
  }

  @override
  Future<void> deleteAttendance(String uid, String id) async {
    attendanceByUid[uid]?.removeWhere((e) => e.id == id);
    _emit();
  }

  @override
  Future<void> seedAttendanceCourses(String uid, List<String> courses) async {
    final list = attendanceByUid.putIfAbsent(uid, () => []);
    for (final course in courses) {
      if (!list.any((e) => e.course == course)) {
        list.add(
          AttendanceEntry(id: _id(), course: course, held: 0, attended: 0),
        );
      }
    }
    _emit();
  }

  @override
  Stream<List<PortalNotice>> noticesStream() =>
      _watch(() => noticeList.reversed.toList());

  @override
  Future<void> postNotice({required String title, required String body}) async {
    noticeList.add(
      PortalNotice(
        id: _id(),
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );
    _emit();
  }
}
