import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CustomerRequestsScreen extends ConsumerStatefulWidget {
  const CustomerRequestsScreen({super.key});

  @override
  ConsumerState<CustomerRequestsScreen> createState() =>
      _CustomerRequestsScreenState();
}

class _CustomerRequestsScreenState
    extends ConsumerState<CustomerRequestsScreen> {
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final res = await SupabaseService.client
          .from('emergency_requests')
          .select()
          .eq('customer_id', userId)
          .order('request_date', ascending: false);
      setState(() {
        _requests = (res as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitRequest(String type, String note) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    setState(() => _isSubmitting = true);
    try {
      await SupabaseService.client.from('emergency_requests').insert({
        'customer_id': userId,
        'type': type,
        'note': note,
        'request_date': DateTime.now().toIso8601String().split('T')[0],
        'is_resolved': false,
      });
      await _loadRequests();
    } catch (_) {
      // show error
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Requests')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewRequestSheet(context),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_outlined,
                          size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text('No requests yet',
                          style: AppTypography.textTheme.titleMedium
                              ?.copyWith(
                                  color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final r = _requests[i];
                    final isResolved =
                        r['is_resolved'] as bool? ?? false;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isResolved
                              ? AppColors.secondary
                                  .withValues(alpha: 0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(r['type'] as String? ?? '',
                                    style: AppTypography
                                        .textTheme.titleSmall),
                                if ((r['note'] as String? ?? '')
                                    .isNotEmpty)
                                  Text(r['note'] as String,
                                      style: AppTypography
                                          .textTheme.bodySmall),
                                Text(
                                  r['request_date'] as String? ?? '',
                                  style: AppTypography
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                          color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isResolved
                                  ? AppColors.secondary
                                      .withValues(alpha: 0.12)
                                  : AppColors.warning
                                      .withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              isResolved ? 'Resolved' : 'Pending',
                              style: AppTypography.textTheme.labelSmall
                                  ?.copyWith(
                                      color: isResolved
                                          ? AppColors.secondary
                                          : AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  void _showNewRequestSheet(BuildContext context) {
    String type = 'extra_milk';
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Request',
                  style: AppTypography.textTheme.titleLarge),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                      value: 'extra_milk',
                      child: Text('Extra Milk')),
                  DropdownMenuItem(
                      value: 'vacation', child: Text('Vacation')),
                  DropdownMenuItem(
                      value: 'complaint', child: Text('Complaint')),
                  DropdownMenuItem(
                      value: 'other', child: Text('Other')),
                ],
                onChanged: (v) =>
                    setModalState(() => type = v ?? 'extra_milk'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          _submitRequest(type, noteCtrl.text.trim());
                          Navigator.pop(ctx);
                        },
                  child: const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
