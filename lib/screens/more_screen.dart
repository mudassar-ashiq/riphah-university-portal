import 'package:flutter/material.dart';

import '../models/portal_models.dart';
import '../services/auth_service.dart';
import '../services/portal_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_widgets.dart';
import 'admin_screen.dart';
import 'attendance_screen.dart';
import 'detail_screens.dart';
import 'fees_screen.dart';
import 'notices_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.uid,
    required this.authService,
    required this.repository,
  });

  final String uid;
  final AuthService authService;
  final PortalRepository repository;

  @override
  Widget build(BuildContext context) {
    // The Admin Panel tile is rendered only for profiles whose role
    // is 'admin'; everyone else never sees it.
    return StreamBuilder<UserProfile?>(
      stream: repository.profileStream(uid),
      builder: (context, snapshot) {
        return _buildList(context, isAdmin: snapshot.data?.isAdmin == true);
      },
    );
  }

  Widget _buildList(BuildContext context, {required bool isAdmin}) {
    final items = <({IconData icon, String label, String sub, Widget page})>[
      (
        icon: Icons.receipt_long_outlined,
        label: 'Fees & Challans',
        sub: 'Your own fee entries and dues',
        page: FeesScreen(uid: uid, repository: repository),
      ),
      (
        icon: Icons.fact_check_outlined,
        label: 'Attendance',
        sub: 'Your attendance record per course',
        page: AttendanceScreen(uid: uid, repository: repository),
      ),
      (
        icon: Icons.campaign_outlined,
        label: 'Notices',
        sub: 'Announcements for all students',
        page: NoticesScreen(uid: uid, repository: repository),
      ),
      (
        icon: Icons.local_library_outlined,
        label: 'Library',
        sub: 'Campus library information',
        page: const LibraryScreen(),
      ),
      (
        icon: Icons.groups_outlined,
        label: 'Faculty Directory',
        sub: 'Teachers, emails and office hours',
        page: const FacultyScreen(),
      ),
      (
        icon: Icons.event_outlined,
        label: 'Events',
        sub: 'Seminars, fests and activities',
        page: const EventsScreen(),
      ),
      (
        icon: Icons.person_outline_rounded,
        label: 'My Profile',
        sub: 'Your student record and details',
        page: ProfileScreen(
          uid: uid,
          authService: authService,
          repository: repository,
        ),
      ),
    ];

    if (isAdmin) {
      items.insert(
        0,
        (
          icon: Icons.admin_panel_settings_outlined,
          label: 'Admin Panel',
          sub: 'Registered students and notices',
          page: AdminPanelScreen(uid: uid, repository: repository),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const ScreenTitle(
          title: 'More',
          subtitle: 'Everything else in your university portal',
        ),
        for (final item in items) ...[
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF003366).withValues(alpha: 0.14),
                  ),
                  child: Icon(item.icon, color: const Color(0xFF003366)),
                ),
                title: Text(
                  item.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F3648),
                  ),
                ),
                subtitle: Text(
                  item.sub,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF8A8F98),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8A8F98),
                ),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => item.page)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
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
              onTap: () => authService.signOut(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const InfoNote(),
      ],
    );
  }
}
