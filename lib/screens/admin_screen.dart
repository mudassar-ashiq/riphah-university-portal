import 'package:flutter/material.dart';

import '../models/portal_models.dart';
import '../services/portal_repository.dart';
import '../utils/format.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_widgets.dart';
import 'detail_screens.dart';

/// Admin panel: only reachable from the More tab when the signed-in
/// profile's role is 'admin' (the tile itself is hidden otherwise,
/// and the Firestore rules enforce the same boundary: admins may read
/// every profile document, and only admins may write/delete notices).
///
/// Shows the registered-student list, a post-notice form and the
/// posted notices with delete controls. Students' results, fees and
/// attendance stay private — those subcollections are owner-only.
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({
    super.key,
    required this.uid,
    required this.repository,
  });

  final String uid;
  final PortalRepository repository;

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and a message.')),
      );
      return;
    }
    setState(() => _posting = true);
    try {
      await widget.repository.postNotice(title: title, body: body);
      _titleController.clear();
      _bodyController.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not post the notice.')),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _confirmDelete(PortalNotice notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete notice?',
          style: TextStyle(color: Color(0xFF2F3648)),
        ),
        content: Text(
          '\u201C${notice.title}\u201D will be removed for all students.',
          style: TextStyle(color: Color(0xFF5A6474)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || notice.id == null) return;
    try {
      await widget.repository.deleteNotice(notice.id!);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the notice.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Admin Panel',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _statsRow(),
          const SizedBox(height: 22),
          _sectionHeader('Registered Students'),
          _studentsList(),
          const SizedBox(height: 10),
          _sectionHeader('Post Notice'),
          _postCard(),
          const SizedBox(height: 22),
          _sectionHeader('Posted Notices'),
          _noticesList(),
          const InfoNote(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2F3648),
        ),
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<UserProfile>>(
            stream: widget.repository.watchAllProfiles(),
            builder: (context, snapshot) => _statCard(
              icon: Icons.groups_outlined,
              label: 'Students',
              value: snapshot.hasData ? '${snapshot.data!.length}' : '\u2013',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StreamBuilder<List<PortalNotice>>(
            stream: widget.repository.noticesStream(),
            builder: (context, snapshot) => _statCard(
              icon: Icons.campaign_outlined,
              label: 'Notices',
              value: snapshot.hasData ? '${snapshot.data!.length}' : '\u2013',
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF003366), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2F3648),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF8A8F98),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentsList() {
    return StreamBuilder<List<UserProfile>>(
      stream: widget.repository.watchAllProfiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF003366)),
            ),
          );
        }
        if (snapshot.hasError) {
          return const EmptyState(
            icon: Icons.error_outline_rounded,
            message: 'Could not load the student list.',
          );
        }
        final students = snapshot.data ?? const <UserProfile>[];
        if (students.isEmpty) {
          return const EmptyState(
            icon: Icons.groups_outlined,
            message: 'No students have registered yet.',
          );
        }
        return Column(
          children: [
            for (final p in students) ...[
              _studentCard(p),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _studentCard(UserProfile profile) {
    final isSelf = profile.uid == widget.uid;
    final subStyle = TextStyle(
      fontSize: 12.5,
      color: Color(0xFF8A8F98),
    );
    return GlassCard(
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
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF003366),
            ),
          ),
          title: Text(
            isSelf ? '${profile.name} (You)' : profile.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F3648),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.roll, style: subStyle),
              Text(
                '${profile.program} \u00B7 Semester ${profile.semester} '
                '\u00B7 Section ${profile.section}',
                style: subStyle,
              ),
              Text(profile.email, style: subStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _postCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: glassFieldDecoration(
              label: 'Title',
              icon: Icons.title_rounded,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 3,
            decoration: glassFieldDecoration(
              label: 'Message',
              icon: Icons.notes_rounded,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _posting ? null : _post,
              icon: const Icon(Icons.send_rounded, size: 17),
              label: const Text('Post notice'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC22),
                foregroundColor: const Color(0xFF001E35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticesList() {
    return StreamBuilder<List<PortalNotice>>(
      stream: widget.repository.noticesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF003366)),
            ),
          );
        }
        if (snapshot.hasError) {
          return const EmptyState(
            icon: Icons.error_outline_rounded,
            message: 'Could not load the notices.',
          );
        }
        final notices = snapshot.data ?? const <PortalNotice>[];
        if (notices.isEmpty) {
          return const EmptyState(
            icon: Icons.campaign_outlined,
            message: 'No notices posted yet.',
          );
        }
        return Column(
          children: [
            for (final n in notices) ...[
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
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF003366).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            'Notice',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF003366),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (n.createdAt != null)
                          Text(
                            formatDate(n.createdAt!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A8F98),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFDC2626),
                            size: 20,
                          ),
                          tooltip: 'Delete notice',
                          onPressed:
                              n.id == null ? null : () => _confirmDelete(n),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      n.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2F3648),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n.body,
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
          ],
        );
      },
    );
  }
}
