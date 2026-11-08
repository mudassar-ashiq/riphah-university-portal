import 'package:flutter/material.dart';

import '../models/portal_models.dart';
import '../services/portal_repository.dart';
import '../utils/format.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_widgets.dart';

/// Results tab: the student's own result entries, stored privately
/// under users/{uid}/results in Firestore.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.uid, required this.repository});

  final String uid;
  final PortalRepository repository;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _subjectController = TextEditingController();
  final _totalController = TextEditingController();
  final _obtainedController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _totalController.dispose();
    _obtainedController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addResult() async {
    final subject = _subjectController.text.trim();
    final total = double.tryParse(_totalController.text.trim());
    final obtained = double.tryParse(_obtainedController.text.trim());
    if (subject.isEmpty) {
      _snack('Please enter the subject name.');
      return;
    }
    if (total == null || total <= 0) {
      _snack('Total marks must be a number greater than zero.');
      return;
    }
    if (obtained == null || obtained < 0 || obtained > total) {
      _snack('Obtained marks must be between 0 and the total marks.');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.repository.addResult(
        widget.uid,
        ResultEntry(
          subject: subject,
          totalMarks: total,
          obtainedMarks: obtained,
        ),
      );
      _subjectController.clear();
      _totalController.clear();
      _obtainedController.clear();
    } catch (_) {
      _snack('Could not save the result. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const ScreenTitle(
          title: 'Results',
          subtitle: 'Your own result entries',
        ),
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a result',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2F3648),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _subjectController,
                decoration: glassFieldDecoration(
                  label: 'Subject',
                  icon: Icons.menu_book_outlined,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _obtainedController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: glassFieldDecoration(label: 'Obtained marks'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _totalController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: glassFieldDecoration(label: 'Total marks'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _addResult,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add result'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC22),
                foregroundColor: const Color(0xFF001E35),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        StreamBuilder<List<ResultEntry>>(
          stream: widget.repository.resultsStream(widget.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF003366)),
                ),
              );
            }
            final results = snapshot.data ?? const <ResultEntry>[];
            if (results.isEmpty) {
              return const EmptyState(
                icon: Icons.assessment_outlined,
                message:
                    'No results yet. Add your first result using the form above.',
              );
            }
            return Column(
              children: [
                for (final r in results) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.subject,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2F3648),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${formatMarks(r.obtainedMarks)} / '
                                '${formatMarks(r.totalMarks)} marks',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF5A6474),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF003366).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${r.percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF003366),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFF8A8F98),
                            size: 20,
                          ),
                          onPressed: r.id == null
                              ? null
                              : () => widget.repository
                                  .deleteResult(widget.uid, r.id!),
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
