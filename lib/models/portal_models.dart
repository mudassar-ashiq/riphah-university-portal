// Data models for the multi-user portal.
//
// Shapes match the published Firestore rules exactly:
// - users/{uid}                 -> [UserProfile]
// - users/{uid}/results/{id}    -> [ResultEntry]
// - users/{uid}/fees/{id}       -> [FeeEntry]
// - users/{uid}/attendance/{id} -> [AttendanceEntry]
// - notices/{id}                -> [PortalNotice]

/// Percentage helper shared by results and attendance.
double percentOf(num part, num whole) {
  if (whole <= 0) return 0;
  return part / whole * 100;
}

/// Whether a profile belongs to the class whose real timetable and
/// course list are bundled with the app: BSSE, section A, semester 5.
///
/// Program is matched loosely because students type it in different
/// ways ("BSSE", "BS Software Engineering", ...). Section is
/// normalised the same way ("A", "BSSE-A", "Section A" all count).
bool matchesBsseASemester5({
  required String program,
  required String section,
  required int semester,
}) {
  if (semester != 5) return false;
  final p = program.toUpperCase();
  final programOk = p.contains('BSSE') || p.contains('SOFTWARE ENGINEERING');
  if (!programOk) return false;
  final s = section
      .toUpperCase()
      .replaceAll('BSSE', '')
      .replaceAll('SECTION', '')
      .replaceAll('-', '')
      .replaceAll(' ', '')
      .trim();
  return s == 'A';
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.roll,
    required this.program,
    required this.semester,
    required this.section,
    required this.email,
    this.role = 'student',
  });

  final String uid;
  final String name;
  final String roll;
  final String program;
  final int semester;
  final String section;
  final String email;
  final String role;

  bool get isAdmin => role == 'admin';

  bool get hasBundledTimetable => matchesBsseASemester5(
        program: program,
        section: section,
        semester: semester,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'roll': roll,
        'program': program,
        'semester': semester,
        'section': section,
        'email': email,
        'role': role,
      };

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      roll: (map['roll'] as String?) ?? '',
      program: (map['program'] as String?) ?? '',
      semester: (map['semester'] as num?)?.toInt() ?? 1,
      section: (map['section'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      role: (map['role'] as String?) ?? 'student',
    );
  }

  UserProfile copyWith({String? role}) {
    return UserProfile(
      uid: uid,
      name: name,
      roll: roll,
      program: program,
      semester: semester,
      section: section,
      email: email,
      role: role ?? this.role,
    );
  }
}

class ResultEntry {
  const ResultEntry({
    this.id,
    required this.subject,
    required this.totalMarks,
    required this.obtainedMarks,
  });

  final String? id;
  final String subject;
  final double totalMarks;
  final double obtainedMarks;

  double get percentage => percentOf(obtainedMarks, totalMarks);

  Map<String, dynamic> toMap() => {
        'subject': subject,
        'totalMarks': totalMarks,
        'obtainedMarks': obtainedMarks,
      };

  factory ResultEntry.fromMap(String id, Map<String, dynamic> map) {
    return ResultEntry(
      id: id,
      subject: (map['subject'] as String?) ?? '',
      totalMarks: (map['totalMarks'] as num?)?.toDouble() ?? 0,
      obtainedMarks: (map['obtainedMarks'] as num?)?.toDouble() ?? 0,
    );
  }
}

class FeeEntry {
  const FeeEntry({
    this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.paid = false,
  });

  final String? id;
  final String title;
  final int amount; // PKR
  final DateTime dueDate;
  final bool paid;

  Map<String, dynamic> toMap() => {
        'title': title,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'paid': paid,
      };

  factory FeeEntry.fromMap(String id, Map<String, dynamic> map) {
    return FeeEntry(
      id: id,
      title: (map['title'] as String?) ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      dueDate:
          DateTime.tryParse((map['dueDate'] as String?) ?? '') ?? DateTime.now(),
      paid: (map['paid'] as bool?) ?? false,
    );
  }

  FeeEntry copyWith({bool? paid}) {
    return FeeEntry(
      id: id,
      title: title,
      amount: amount,
      dueDate: dueDate,
      paid: paid ?? this.paid,
    );
  }
}

class AttendanceEntry {
  const AttendanceEntry({
    this.id,
    required this.course,
    required this.held,
    required this.attended,
  });

  final String? id;
  final String course;
  final int held;
  final int attended;

  double get percentage => percentOf(attended, held);

  Map<String, dynamic> toMap() => {
        'course': course,
        'held': held,
        'attended': attended,
      };

  factory AttendanceEntry.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceEntry(
      id: id,
      course: (map['course'] as String?) ?? '',
      held: (map['held'] as num?)?.toInt() ?? 0,
      attended: (map['attended'] as num?)?.toInt() ?? 0,
    );
  }
}

class PortalNotice {
  const PortalNotice({
    this.id,
    required this.title,
    required this.body,
    this.createdAt,
  });

  final String? id;
  final String title;
  final String body;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
      };

  factory PortalNotice.fromMap(
    String id,
    Map<String, dynamic> map, {
    DateTime? createdAt,
  }) {
    return PortalNotice(
      id: id,
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      createdAt: createdAt,
    );
  }
}
