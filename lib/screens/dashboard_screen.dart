import 'package:flutter/material.dart';

import '../models/portal_models.dart';
import '../services/auth_service.dart';
import '../services/portal_repository.dart';
import '../utils/format.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_widgets.dart';
import 'detail_screens.dart';
import 'fees_screen.dart';
import 'notices_screen.dart';

/// Home tab: the signed-in student's own profile, their pending-fees
/// total, (for BSSE-A Semester 5) the next class from the real
/// timetable, and the latest notices from Firestore.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
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
    return StreamBuilder<UserProfile?>(
      stream: repository.profileStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
          );
        }
        final profile = snapshot.data;
        if (profile == null) {
          return _ProfileMissing(authService: authService);
        }
        return _DashboardBody(
          profile: profile,
          authService: authService,
          repository: repository,
        );
      },
    );
  }
}

class _ProfileMissing extends StatelessWidget {
  const _ProfileMissing({required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EmptyState(
            icon: Icons.person_off_outlined,
            message:
                'Your profile could not be found. Please log out and '
                'sign up again so your student profile is saved.',
          ),
          OutlinedButton.icon(
            onPressed: () => authService.signOut(),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Log Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF87171),
              side: BorderSide(
                color: const Color(0xFFF87171).withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.profile,
    required this.authService,
    required this.repository,
  });

  final UserProfile profile;
  final AuthService authService;
  final PortalRepository repository;

  String get _initial =>
      profile.name.trim().isEmpty ? '?' : profile.name.trim()[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/riphah_building.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF050B14).withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: 19,
                          color: Color(0xFF22D3EE),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Riphah International University — Sahiwal Campus',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 29),
                      child: Text(
                        'Student Portal · ${profile.program} · '
                        'Semester ${profile.semester}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF22D3EE).withValues(alpha: 0.18),
              child: Text(
                _initial,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF22D3EE),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assalam-o-Alaikum,',
                    style: TextStyle(fontSize: 13, color: Colors.white60),
                  ),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${profile.roll} · Section ${profile.section}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoticesScreen(
                    uid: profile.uid,
                    repository: repository,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semester',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.semester}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      profile.program,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: StreamBuilder<List<FeeEntry>>(
                stream: repository.feesStream(profile.uid),
                builder: (context, feesSnap) {
                  final pending = (feesSnap.data ?? const <FeeEntry>[])
                      .where((f) => !f.paid)
                      .fold<int>(0, (sum, f) => sum + f.amount);
                  return GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fees pending',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupees(pending),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'From your own fee entries',
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Quick access',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.92,
          children: [
            _QuickAction(
              icon: Icons.receipt_long_outlined,
              label: 'Fees',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      FeesScreen(uid: profile.uid, repository: repository),
                ),
              ),
            ),
            _QuickAction(
              icon: Icons.campaign_outlined,
              label: 'Notices',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoticesScreen(
                    uid: profile.uid,
                    repository: repository,
                  ),
                ),
              ),
            ),
            _QuickAction(
              icon: Icons.local_library_outlined,
              label: 'Library',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LibraryScreen()),
              ),
            ),
            _QuickAction(
              icon: Icons.event_outlined,
              label: 'Events',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EventsScreen()),
              ),
            ),
          ],
        ),
        if (profile.hasBundledTimetable) ...[
          const SizedBox(height: 22),
          const Text(
            'Next class',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF22D3EE).withValues(alpha: 0.15),
                  ),
                  child:
                      const Icon(Icons.code_rounded, color: Color(0xFF22D3EE)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Software Construction and Development',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Monday · 08:30 – 09:30 · Room B4',
                        style: TextStyle(fontSize: 12.5, color: Colors.white60),
                      ),
                      Text(
                        'Ms Afia Afzaal',
                        style: TextStyle(fontSize: 12.5, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        const Text(
          'Latest notices',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<PortalNotice>>(
          stream: repository.noticesStream(),
          builder: (context, snap) {
            final notices = (snap.data ?? const <PortalNotice>[]).take(3);
            if (notices.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No notices yet. New announcements will appear here.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final notice in notices) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const _NoticeChip(),
                            const Spacer(),
                            if (notice.createdAt != null)
                              Text(
                                formatDate(notice.createdAt!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notice.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
        const InfoNote(),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF22D3EE), size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeChip extends StatelessWidget {
  const _NoticeChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF22D3EE).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        'Notice',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF22D3EE),
        ),
      ),
    );
  }
}
