import 'package:flutter/material.dart';

import '../models/portal_models.dart';
import '../services/portal_repository.dart';
import '../utils/format.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_widgets.dart';
import 'detail_screens.dart';

/// Fees & Challans: the student's own fee entries, stored privately
/// under users/{uid}/fees in Firestore.
class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key, required this.uid, required this.repository});

  final String uid;
  final PortalRepository repository;

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _addFee() async {
    final title = _titleController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());
    if (title.isEmpty) {
      _snack('Please enter a title for the fee.');
      return;
    }
    if (amount == null || amount <= 0) {
      _snack('Amount must be a whole number greater than zero.');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.repository.addFee(
        widget.uid,
        FeeEntry(title: title, amount: amount, dueDate: _dueDate),
      );
      _titleController.clear();
      _amountController.clear();
    } catch (_) {
      _snack('Could not save the fee. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Fees & Challans',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          StreamBuilder<List<FeeEntry>>(
            stream: widget.repository.feesStream(widget.uid),
            builder: (context, snapshot) {
              final fees = snapshot.data ?? const <FeeEntry>[];
              final outstanding = fees
                  .where((f) => !f.paid)
                  .fold<int>(0, (sum, f) => sum + f.amount);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outstanding balance',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupees(outstanding),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'From your own fee entries below',
                          style: TextStyle(fontSize: 12.5, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _addFeeCard(),
                  const SizedBox(height: 18),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF22D3EE)),
                      ),
                    )
                  else if (fees.isEmpty)
                    const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message:
                          'No fee entries yet. Add your first challan using the form above.',
                    )
                  else
                    for (final f in fees) ...[
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${formatRupees(f.amount)} · Due '
                                    '${formatDate(f.dueDate)}',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _PaidChip(paid: f.paid),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.white54,
                                size: 20,
                              ),
                              color: const Color(0xFF0B1626),
                              onSelected: (action) {
                                if (f.id == null) return;
                                if (action == 'toggle') {
                                  widget.repository
                                      .setFeePaid(widget.uid, f.id!, !f.paid);
                                } else if (action == 'delete') {
                                  widget.repository
                                      .deleteFee(widget.uid, f.id!);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Text(
                                    f.paid
                                        ? 'Mark as pending'
                                        : 'Mark as paid',
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
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
      ),
    );
  }

  Widget _addFeeCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a fee / challan',
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
              icon: Icons.receipt_long_outlined,
              hint: 'e.g. Semester fee — Installment 1',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: glassFieldDecoration(
                    label: 'Amount (PKR)',
                    icon: Icons.payments_outlined,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: glassFieldDecoration(
                      label: 'Due date',
                      icon: Icons.event_outlined,
                    ),
                    child: Text(
                      formatDate(_dueDate),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _saving ? null : _addFee,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add fee'),
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

class _PaidChip extends StatelessWidget {
  const _PaidChip({required this.paid});

  final bool paid;

  @override
  Widget build(BuildContext context) {
    final color = paid ? const Color(0xFF34D399) : const Color(0xFFFBBF24);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        paid ? 'Paid' : 'Pending',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
