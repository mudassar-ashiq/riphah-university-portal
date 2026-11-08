import 'package:flutter/material.dart';

import '../data/portal_data.dart';
import '../models/portal_models.dart';
import '../services/portal_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_widgets.dart';

/// Courses tab: the bundled real course list is for BSSE, section A,
/// semester 5 — students with a matching profile see it, everyone
/// else gets a clear empty state.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key, required this.uid, required this.repository});

  final String uid;
  final PortalRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: repository.profileStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF003366)),
          );
        }
        final profile = snapshot.data;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const ScreenTitle(title: 'My Courses'),
            if (profile == null || !profile.hasBundledTimetable)
              const EmptyState(
                icon: Icons.menu_book_outlined,
                message: 'Your class timetable has not been added yet.',
              )
            else ...[
              Text(
                '${courses.length} courses · '
                '${courses.fold<int>(0, (sum, c) => sum + c.creditHours)} '
                'credit hours · Semester 5',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF5A6474),
                ),
              ),
              const SizedBox(height: 16),
              for (final course in courses) ...[
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF003366).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.code,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF003366),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${course.creditHours} Cr Hrs',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF8A8F98),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F3648),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${course.instructor} · ${course.room}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A6474),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ],
            const InfoNote(),
          ],
        );
      },
    );
  }
}
