import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/portal_models.dart';

/// All Firestore access for the portal, behind an interface so widget
/// tests can substitute an in-memory fake.
///
/// Paths (matching the published security rules):
/// - users/{uid}, users/{uid}/results, users/{uid}/fees,
///   users/{uid}/attendance — owner-only
/// - notices — readable by any signed-in user, writable by admins
abstract class PortalRepository {
  Stream<UserProfile?> profileStream(String uid);

  Future<void> createProfile(UserProfile profile);

  Stream<List<ResultEntry>> resultsStream(String uid);
  Future<void> addResult(String uid, ResultEntry entry);
  Future<void> deleteResult(String uid, String id);

  Stream<List<FeeEntry>> feesStream(String uid);
  Future<void> addFee(String uid, FeeEntry entry);
  Future<void> setFeePaid(String uid, String id, bool paid);
  Future<void> deleteFee(String uid, String id);

  Stream<List<AttendanceEntry>> attendanceStream(String uid);
  Future<void> upsertAttendance(String uid, AttendanceEntry entry);
  Future<void> deleteAttendance(String uid, String id);

  /// Seeds attendance rows for the given course names with 0/0 counts.
  Future<void> seedAttendanceCourses(String uid, List<String> courses);

  Stream<List<PortalNotice>> noticesStream();
  Future<void> postNotice({required String title, required String body});
}

class FirestorePortalRepository implements PortalRepository {
  FirestorePortalRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _sub(String uid, String name) =>
      _userDoc(uid).collection(name);

  @override
  Stream<UserProfile?> profileStream(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (!snap.exists || data == null) return null;
      return UserProfile.fromMap(uid, data);
    });
  }

  @override
  Future<void> createProfile(UserProfile profile) {
    return _userDoc(profile.uid).set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<ResultEntry>> resultsStream(String uid) {
    return _sub(uid, 'results')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (qs) => qs.docs
              .map((d) => ResultEntry.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> addResult(String uid, ResultEntry entry) {
    return _sub(uid, 'results').add({
      ...entry.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteResult(String uid, String id) {
    return _sub(uid, 'results').doc(id).delete();
  }

  @override
  Stream<List<FeeEntry>> feesStream(String uid) {
    return _sub(uid, 'fees').snapshots().map((qs) {
      final fees = qs.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        final due = data['dueDate'];
        if (due is Timestamp) {
          data['dueDate'] = due.toDate().toIso8601String();
        }
        return FeeEntry.fromMap(d.id, data);
      }).toList();
      fees.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return fees;
    });
  }

  @override
  Future<void> addFee(String uid, FeeEntry entry) {
    return _sub(uid, 'fees').add({
      'title': entry.title,
      'amount': entry.amount,
      'dueDate': Timestamp.fromDate(entry.dueDate),
      'paid': entry.paid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setFeePaid(String uid, String id, bool paid) {
    return _sub(uid, 'fees').doc(id).update({'paid': paid});
  }

  @override
  Future<void> deleteFee(String uid, String id) {
    return _sub(uid, 'fees').doc(id).delete();
  }

  @override
  Stream<List<AttendanceEntry>> attendanceStream(String uid) {
    return _sub(uid, 'attendance').snapshots().map((qs) {
      final rows =
          qs.docs.map((d) => AttendanceEntry.fromMap(d.id, d.data())).toList();
      rows.sort((a, b) => a.course.compareTo(b.course));
      return rows;
    });
  }

  @override
  Future<void> upsertAttendance(String uid, AttendanceEntry entry) async {
    if (entry.id != null) {
      await _sub(uid, 'attendance').doc(entry.id).set(entry.toMap());
      return;
    }
    // One row per course name: update the existing row if present.
    final existing =
        await _sub(uid, 'attendance').where('course', isEqualTo: entry.course).limit(1).get();
    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.set(entry.toMap());
    } else {
      await _sub(uid, 'attendance').add(entry.toMap());
    }
  }

  @override
  Future<void> deleteAttendance(String uid, String id) {
    return _sub(uid, 'attendance').doc(id).delete();
  }

  @override
  Future<void> seedAttendanceCourses(String uid, List<String> courses) async {
    final batch = _db.batch();
    for (final course in courses) {
      final ref = _sub(uid, 'attendance').doc();
      batch.set(ref, {'course': course, 'held': 0, 'attended': 0});
    }
    await batch.commit();
  }

  @override
  Stream<List<PortalNotice>> noticesStream() {
    return _db
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (qs) => qs.docs.map((d) {
            final ts = d.data()['createdAt'];
            return PortalNotice.fromMap(
              d.id,
              d.data(),
              createdAt: ts is Timestamp ? ts.toDate() : null,
            );
          }).toList(),
        );
  }

  @override
  Future<void> postNotice({required String title, required String body}) {
    return _db.collection('notices').add({
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
