import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/portal_repository.dart';
import 'courses_screen.dart';
import 'dashboard_screen.dart';
import 'more_screen.dart';
import 'results_screen.dart';
import 'timetable_screen.dart';

/// App shell: the five portal tabs on the cream background, with a
/// floating white bottom navigation bar in the Riphah colours —
/// navy for the selected tab and a small gold indicator above it.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.uid,
    required this.authService,
    required this.repository,
  });

  final String uid;
  final AuthService authService;
  final PortalRepository repository;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = <({IconData icon, String label})>[
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.menu_book_rounded, label: 'Courses'),
    (icon: Icons.calendar_month_rounded, label: 'Timetable'),
    (icon: Icons.assessment_rounded, label: 'Results'),
    (icon: Icons.grid_view_rounded, label: 'More'),
  ];

  late final List<Widget> _screens = [
    DashboardScreen(
      uid: widget.uid,
      authService: widget.authService,
      repository: widget.repository,
    ),
    CoursesScreen(uid: widget.uid, repository: widget.repository),
    TimetableScreen(uid: widget.uid, repository: widget.repository),
    ResultsScreen(uid: widget.uid, repository: widget.repository),
    MoreScreen(
      uid: widget.uid,
      authService: widget.authService,
      repository: widget.repository,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF003366).withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF001E35).withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _tabs.length; i++)
                _NavItem(
                  icon: _tabs[i].icon,
                  label: _tabs[i].label,
                  selected: i == _index,
                  onTap: () => setState(() => _index = i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? const Color(0xFF003366)
        : const Color(0xFF8A8F98);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFFCC22) : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 5),
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
