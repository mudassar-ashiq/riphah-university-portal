import 'package:flutter/material.dart';

import '../models/portal_models.dart';
import '../services/portal_repository.dart';
import '../utils/format.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_widgets.dart';
import 'detail_screens.dart';

/// Notices: streamed live from the shared Firestore `notices`
/// collection (newest first). Students whose profile role is
/// 'admin' additionally get a Post Notice form and a delete button
/// on each notice — the security rules enforce the same check on
/// the server.
class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key, required this.uid, required this.repository});

  final String uid;
  final PortalRepository repository;

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
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
        backgroundColor: const Color(0xFF0B1626),
        title: const Text(
          'Delete notice?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '\u201C${notice.title}\u201D will be removed for all students.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
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
              style: TextStyle(color: Color(0xFFF87171)),
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
      title: 'Notices',
      child: StreamBuilder<UserProfile?>(
        stream: widget.repository.profileStream(widget.uid),
        builder: (context, profileSnapshot) {
          final isAdmin = profileSnapshot.data?.isAdmin == true;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _postCard(),
                ),
              _noticesList(isAdmin),
              const InfoNote(),
            ],
          );
        },
      ),
    );
  }

  Widget _noticesList(bool isAdmin) {
    return StreamBuilder<List<PortalNotice>>(
      stream: widget.repository.noticesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
            ),
          );
        }
        final notices = snapshot.data ?? const <PortalNotice>[];
        if (notices.isEmpty) {
          return const EmptyState(
            icon: Icons.campaign_outlined,
            message: 'No notices yet. New announcements will appear here.',
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
                                const Color(0xFF22D3EE).withValues(alpha: 0.15),
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
                        ),
                        const Spacer(),
                        if (n.createdAt != null)
                          Text(
                            formatDate(n.createdAt!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        if (isAdmin)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFF87171),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n.body,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.7),
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

  Widget _postCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Post a notice (admin)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
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
                backgroundColor: const Color(0xFF0891B2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
