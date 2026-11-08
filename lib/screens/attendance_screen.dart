import 'package:flutter/material.dart';

import '../data/portal_data.dart' as data;
import '../models/portal_models.dart';
import '../services/portal_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_widgets.dart';
import 'detail_screens.dart';

/// Attendance: the student's own per-course attendance counts, stored
/// privately under users/{uid}/attendance in Firestore.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    required this.uid,
    required this.repository,
  });

  final String uid;
  final PortalRepository repository;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _courseController = TextEditingController();
  final _heldController = TextEditingController();
  final _attendedController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _courseController.dispose();
    _heldController.dispose();
    _attendedController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _fillForm(AttendanceEntry entry) {
    _courseController.text = entry.course;
    _heldController.text = '${entry.held}';
    _attendedController.text = '${entry.attended}';
  }

  Future<void> _save() async {
    final course = _courseController.text.trim();
    final held = int.tryParse(_heldController.text.trim());
    final attended = int.tryParse(_attendedController.text.trim());
    if (course.isEmpty) {
      _snack('Please enter the course name.');
      return;
    }
    if (held == null || held < 0) {
      _snack('Classes held must be a number (0 or more).');
      return;
    }
    if (attended == null || attended < 0 || attended > held) {
      _snack('Classes attended must be between 0 and the classes held.');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.repository.upsertAttendance(
        widget.uid,
        AttendanceEntry(course: course, held: held, attended: attended),
      );
      _courseController.clear();
      _heldController.clear();
      _attendedController.clear();
    } catch (_) {
      _snack('Could not save attendance. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Attendance',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const ScreenTitle(
            title: 'My attendance',
            subtitle: 'Your own attendance record per course',
          ),
          _formCard(),
          const SizedBox(height: 18),
          StreamBuilder<List<AttendanceEntry>>(
            stream: widget.repository.attendanceStream(widget.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
                  ),
                );
              }
              final rows = snapshot.data ?? const <AttendanceEntry>[];
              if (rows.isEmpty) {
                return Column(
                  children: [
                    const EmptyState(
                      icon: Icons.fact_check_outlined,
                      message:
                          'No attendance entries yet. Add a course using the form above.',
                    ),
                    _seedButton(context),
                  ],
                );
              }
              return Column(
                children: [
                  for (final row in rows) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  row.course,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white54,
                                  size: 19,
                                ),
                                onPressed: () => _fillForm(row),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white54,
                                  size: 19,
                                ),
                                onPressed: row.id == null
                                    ? null
                                    : () => widget.repository.deleteAttendance(
                                          widget.uid,
                                          row.id!,
                                        ),
                              ),
                            ],
                          ),
                          Text(
                            'Attended ${row.attended} of ${row.held} classes',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AttendanceBar(value: row.percentage),
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
      ),
    );
  }

  /// One-tap seeding of the six real BSSE-A Semester 5 course names
  /// (with zero counts) — only for profiles matching that class.
  Widget _seedButton(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: widget.repository.profileStream(widget.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null || !profile.hasBundledTimetable) {
          return const SizedBox.shrink();
        }
        return OutlinedButton.icon(
          onPressed: () => widget.repository.seedAttendanceCourses(
            widget.uid,
            [for (final c in data.courses) c.title],
          ),
          icon: const Icon(Icons.playlist_add_rounded, size: 18),
          label: const Text('Add my six Semester 5 courses'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF22D3EE),
            side: BorderSide(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _formCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add / update a course',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _courseController,
            decoration: glassFieldDecoration(
              label: 'Course',
              icon: Icons.menu_book_outlined,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _heldController,
                  keyboardType: TextInputType.number,
                  decoration: glassFieldDecoration(label: 'Classes held'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _attendedController,
                  keyboardType: TextInputType.number,
                  decoration: glassFieldDecoration(label: 'Classes attended'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0891B2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
