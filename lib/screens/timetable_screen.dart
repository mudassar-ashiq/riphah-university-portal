import 'package:flutter/material.dart';

import '../data/portal_data.dart';
import '../models/portal_models.dart';
import '../services/portal_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_widgets.dart';

/// Timetable tab: the bundled real weekly schedule is for BSSE,
/// section A, semester 5 — shown only to matching profiles.
class TimetableScreen extends StatelessWidget {
  const TimetableScreen({
    super.key,
    required this.uid,
    required this.repository,
  });

  final String uid;
  final PortalRepository repository;

  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

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
        final matches = profile != null && profile.hasBundledTimetable;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            ScreenTitle(
              title: 'Timetable',
              subtitle: matches
                  ? 'Weekly class schedule — BSSE-A, Semester 5'
                  : null,
            ),
            if (!matches)
              const EmptyState(
                icon: Icons.calendar_month_outlined,
                message: 'Your class timetable has not been added yet.',
              )
            else
              for (final day in _days) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 6),
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF22D3EE),
                    ),
                  ),
                ),
                for (final session
                    in timetable.where((s) => s.day == day)) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: Colors.white54,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              session.time.split(' – ').first,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.courseTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${session.courseCode} · ${session.time} · '
                                '${session.room}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
              ],
            const InfoNote(),
          ],
        );
      },
    );
  }
}
