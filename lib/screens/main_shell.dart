import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/portal_repository.dart';
import 'courses_screen.dart';
import 'dashboard_screen.dart';
import 'more_screen.dart';
import 'results_screen.dart';
import 'timetable_screen.dart';

/// App shell: the five portal tabs inside one glow background, with a
/// floating frosted-glass bottom navigation bar.
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
    // GlowBackground is applied per-screen in detail pages; the shell
    // uses the same dark backdrop colour plus its own positioned glows
    // through a Stack so tab switches stay instant.
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF050B14)),
          Positioned(
            top: -100,
            left: -70,
            child: _glow(300, const Color(0xFF0891B2)),
          ),
          Positioned(
            bottom: -120,
            right: -60,
            child: _glow(340, const Color(0xFF6D28D9)),
          ),
          SafeArea(
            child: IndexedStack(index: _index, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
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
        ),
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.5),
              color.withValues(alpha: 0.0),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
