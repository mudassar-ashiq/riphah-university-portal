// Shared static data for the University Portal.
//
// Courses, teachers and the weekly timetable are the real FA24-BSSE-A
// data (official class timetable, generated 25 Oct 2026) and are shown
// to students whose profile matches BSSE, section A, semester 5.
// Faculty and events are shared campus content. Personal data
// (profile, results, fees, attendance, notices) lives in Firestore
// per student — see services/portal_repository.dart.

class Course {
  const Course({
    required this.code,
    required this.title,
    required this.instructor,
    required this.creditHours,
    required this.room,
  });

  final String code;
  final String title;
  final String instructor;
  final int creditHours;
  final String room;
}

const courses = <Course>[
  Course(
    code: 'CS-436',
    title: 'Mobile Application Development',
    instructor: 'Arslan Ali Mansab',
    creditHours: 3,
    room: 'CLab1 · B10',
  ),
  Course(
    code: 'SE-3233',
    title: 'Software Construction and Development',
    instructor: 'Ms Afia Afzaal',
    creditHours: 3,
    room: 'B4 · B10 · CLab7',
  ),
  Course(
    code: 'OS',
    title: 'Operating Systems',
    instructor: 'Mr Hamza Akbar',
    creditHours: 3,
    room: 'B3 · B10 · CLab2',
  ),
  Course(
    code: 'P&DC',
    title: 'Parallel & Distributed Computing',
    instructor: 'Ms Noor ul Huda',
    creditHours: 3,
    room: 'CLab7 · B10 · B2',
  ),
  Course(
    code: 'GmPrg',
    title: 'Game Programming',
    instructor: 'Ms Isha',
    creditHours: 3,
    room: 'CLab8 · B3 · B6',
  ),
  Course(
    code: 'TaBW',
    title: 'Technical & Business Writing',
    instructor: 'Mr Farooq Ahmad',
    creditHours: 2,
    room: 'F-214 · F-217',
  ),
];

class ClassSession {
  const ClassSession({
    required this.day,
    required this.courseCode,
    required this.courseTitle,
    required this.time,
    required this.room,
  });

  final String day;
  final String courseCode;
  final String courseTitle;
  final String time;
  final String room;
}

const timetable = <ClassSession>[
  // Monday
  ClassSession(
    day: 'Monday',
    courseCode: 'SE-3233',
    courseTitle: 'Software Construction and Development',
    time: '08:30 – 09:30',
    room: 'B4',
  ),
  ClassSession(
    day: 'Monday',
    courseCode: 'GmPrg',
    courseTitle: 'Game Programming (Lab)',
    time: '09:30 – 12:30',
    room: 'CLab8',
  ),
  ClassSession(
    day: 'Monday',
    courseCode: 'P&DC',
    courseTitle: 'Parallel & Distributed Computing (Lab)',
    time: '12:30 – 16:00',
    room: 'CLab7',
  ),
  // Tuesday
  ClassSession(
    day: 'Tuesday',
    courseCode: 'GmPrg',
    courseTitle: 'Game Programming',
    time: '11:30 – 12:30',
    room: 'B6',
  ),
  ClassSession(
    day: 'Tuesday',
    courseCode: 'OS',
    courseTitle: 'Operating Systems (Lab)',
    time: '12:30 – 16:00',
    room: 'CLab2',
  ),
  // Wednesday
  ClassSession(
    day: 'Wednesday',
    courseCode: 'GmPrg',
    courseTitle: 'Game Programming',
    time: '08:30 – 09:30',
    room: 'B3',
  ),
  ClassSession(
    day: 'Wednesday',
    courseCode: 'CS-436',
    courseTitle: 'Mobile Application Development (Lab)',
    time: '09:30 – 12:30',
    room: 'CLab1',
  ),
  // Thursday
  ClassSession(
    day: 'Thursday',
    courseCode: 'SE-3233',
    courseTitle: 'Software Construction and Development',
    time: '08:30 – 09:30',
    room: 'B10',
  ),
  ClassSession(
    day: 'Thursday',
    courseCode: 'CS-436',
    courseTitle: 'Mobile Application Development',
    time: '09:30 – 11:30',
    room: 'B10',
  ),
  ClassSession(
    day: 'Thursday',
    courseCode: 'OS',
    courseTitle: 'Operating Systems',
    time: '11:30 – 12:30',
    room: 'B10',
  ),
  ClassSession(
    day: 'Thursday',
    courseCode: 'P&DC',
    courseTitle: 'Parallel & Distributed Computing',
    time: '14:00 – 15:00',
    room: 'B10',
  ),
  ClassSession(
    day: 'Thursday',
    courseCode: 'TaBW',
    courseTitle: 'Technical & Business Writing',
    time: '15:00 – 16:00',
    room: 'F-214',
  ),
  // Friday
  ClassSession(
    day: 'Friday',
    courseCode: 'OS',
    courseTitle: 'Operating Systems',
    time: '08:30 – 09:30',
    room: 'B3',
  ),
  ClassSession(
    day: 'Friday',
    courseCode: 'TaBW',
    courseTitle: 'Technical & Business Writing',
    time: '09:30 – 11:30',
    room: 'F-217',
  ),
  ClassSession(
    day: 'Friday',
    courseCode: 'P&DC',
    courseTitle: 'Parallel & Distributed Computing',
    time: '11:30 – 12:30',
    room: 'B2',
  ),
  ClassSession(
    day: 'Friday',
    courseCode: 'SE-3233',
    courseTitle: 'Software Construction and Development (Lab)',
    time: '12:30 – 16:00',
    room: 'CLab7',
  ),
];

class FacultyMember {
  const FacultyMember({
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.officeHours,
  });

  final String name;
  final String role;
  final String department;
  final String email;
  final String officeHours;
}

const faculty = <FacultyMember>[
  FacultyMember(
    name: 'Arslan Ali Mansab',
    role: 'Lecturer — Mobile Application Development',
    department: 'Computing',
    email: 'arslan.mansab@riphah.edu.pk',
    officeHours: 'Mon & Wed, 12:00 – 1:00 PM',
  ),
  FacultyMember(
    name: 'Ms Afia Afzaal',
    role: 'Lecturer — Software Construction and Development',
    department: 'Computer Science',
    email: 'afia.afzaal@riphah.edu.pk',
    officeHours: 'Tue & Thu, 11:00 AM – 12:00 PM',
  ),
  FacultyMember(
    name: 'Mr Hamza Akbar',
    role: 'Lecturer — Operating Systems',
    department: 'Computing',
    email: 'hamza.akbar@riphah.edu.pk',
    officeHours: 'Tue & Fri, 10:00 – 11:00 AM',
  ),
  FacultyMember(
    name: 'Ms Noor ul Huda',
    role: 'Lecturer — Parallel & Distributed Computing',
    department: 'Computing',
    email: 'noor.huda@riphah.edu.pk',
    officeHours: 'Mon & Thu, 1:00 – 2:00 PM',
  ),
  FacultyMember(
    name: 'Ms Isha',
    role: 'Lecturer — Game Programming',
    department: 'Computing',
    email: 'isha@riphah.edu.pk',
    officeHours: 'Wed, 12:00 – 1:00 PM',
  ),
  FacultyMember(
    name: 'Mr Farooq Ahmad',
    role: 'Lecturer — Technical & Business Writing',
    department: 'Computing',
    email: 'farooq.ahmad@riphah.edu.pk',
    officeHours: 'Thu & Fri, 12:00 – 1:00 PM',
  ),
];

class UniEvent {
  const UniEvent({
    required this.title,
    required this.date,
    required this.venue,
    required this.detail,
  });

  final String title;
  final String date;
  final String venue;
  final String detail;
}

const events = <UniEvent>[
  UniEvent(
    title: 'Riphah Tech Fest 2026',
    date: '28 Nov 2026',
    venue: 'Main Auditorium',
    detail: 'Project exhibition, coding competition and guest talks. Final-year and semester projects can be registered at the Computing Society desk.',
  ),
  UniEvent(
    title: 'Seminar: Careers in Mobile Development',
    date: '18 Nov 2026',
    venue: 'Seminar Hall B',
    detail: 'Industry speakers from Lahore software houses discuss Flutter and cross-platform careers.',
  ),
  UniEvent(
    title: 'Inter-Department Cricket Gala',
    date: '05 Dec 2026',
    venue: 'University Ground',
    detail: 'Team registration closes 25 November at the Sports Office.',
  ),
  UniEvent(
    title: 'Job Fair — Spring 2027 (Early Registration)',
    date: '20 Dec 2026',
    venue: 'Main Auditorium',
    detail: 'Upload your CV to the placement portal before 10 December to get shortlisted early.',
  ),
];
