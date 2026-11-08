import 'package:flutter/material.dart';

import '../data/portal_data.dart';
import '../models/portal_models.dart';
import '../services/auth_service.dart';
import '../services/portal_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_background.dart';
import '../widgets/section_widgets.dart';

/// Base for the pushed detail pages: a navy gradient header in the
/// official Riphah colours over the cream background, so they match
/// the tab screens.
class DetailScaffold extends StatelessWidget {
  const DetailScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF001E35),
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF001E35), Color(0xFF003366)],
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GlowBackground(child: SafeArea(child: child)),
    );
  }
}

/// Campus library — shared information only. Personal loan records
/// are not tracked here; the library office manages borrowing.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF003366).withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: const Color(0xFF003366)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F3648),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF5A6474),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Library',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const ScreenTitle(
            title: 'Central Library',
            subtitle: 'Riphah International University — Sahiwal Campus',
          ),
          _infoCard(
            icon: Icons.local_library_outlined,
            title: 'About the library',
            body:
                'The central library supports students and faculty with '
                'textbooks, reference material and quiet study space for '
                'all programs running at the Sahiwal Campus.',
          ),
          const SizedBox(height: 14),
          _infoCard(
            icon: Icons.menu_book_outlined,
            title: 'Services',
            body:
                'Book borrowing and returns, reading halls, a computer '
                'area for research, past papers and the digital library '
                'for journals and e-books.',
          ),
          const SizedBox(height: 14),
          _infoCard(
            icon: Icons.schedule_outlined,
            title: 'Timings & membership',
            body:
                'Library timings, membership and borrowing limits are '
                'managed by the university library office — please check '
                'the notice board there for the current schedule, '
                'especially during exam weeks.',
          ),
          const SizedBox(height: 14),
          const InfoNote(),
        ],
      ),
    );
  }
}

class FacultyScreen extends StatelessWidget {
  const FacultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Faculty Directory',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          for (final f in faculty) ...[
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF003366)
                        .withValues(alpha: 0.16),
                    child: Text(
                      f.name
                          .replaceAll('Dr. ', '')
                          .replaceAll('Ms ', '')
                          .replaceAll('Mr ', '')[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF003366),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2F3648),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${f.role} · ${f.department}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF5A6474),
                          ),
                        ),
                        Text(
                          f.email,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF8A8F98),
                          ),
                        ),
                        Text(
                          'Office hours: ${f.officeHours}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF8A8F98),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const InfoNote(),
        ],
      ),
    );
  }
}

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Events',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          for (final e in events) ...[
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        size: 18,
                        color: Color(0xFF003366),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        e.date,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF003366),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        e.venue,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF8A8F98),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2F3648),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    e.detail,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: Color(0xFF5A6474),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          const InfoNote(),
        ],
      ),
    );
  }
}

/// My Profile: the signed-in student's own Firestore profile, with a
/// working Log Out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.uid,
    required this.authService,
    required this.repository,
  });

  final String uid;
  final AuthService authService;
  final PortalRepository repository;

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8A8F98),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2F3648),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'My Profile',
      child: StreamBuilder<UserProfile?>(
        stream: repository.profileStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF003366)),
            );
          }
          final profile = snapshot.data;
          if (profile == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyState(
                icon: Icons.person_off_outlined,
                message: 'Your profile could not be found.',
              ),
            );
          }
          final initial = profile.name.trim().isEmpty
              ? '?'
              : profile.name.trim()[0].toUpperCase();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor:
                          const Color(0xFF003366).withValues(alpha: 0.12),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF003366),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2F3648),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.program,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5A6474),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _row('Roll / CMS No', profile.roll),
                    _row('Section', profile.section),
                    _row('Semester', '${profile.semester}'),
                    _row('Program', profile.program),
                    _row('Email', profile.email),
                    _row('Account type', profile.isAdmin ? 'Admin' : 'Student'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFDC2626).withValues(alpha: 0.14),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    subtitle: Text(
                      'Sign out of your account',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF8A8F98),
                      ),
                    ),
                    onTap: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      }
                    },
                  ),
                ),
              ),
              const InfoNote(),
            ],
          );
        },
      ),
    );
  }
}
