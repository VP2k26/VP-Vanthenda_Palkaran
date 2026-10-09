import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/manager_scaffold.dart';

class VacationRequest {
  final String id;
  final String customerId;
  final String customerName;
  final DateTime fromDate;
  final DateTime toDate;
  final String? reason;
  final String status;

  const VacationRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.fromDate,
    required this.toDate,
    this.reason,
    required this.status,
  });

  factory VacationRequest.fromJson(Map<String, dynamic> json) =>
      VacationRequest(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        customerName: json['customers'] != null
            ? (json['customers']['full_name'] as String? ?? 'Unknown')
            : 'Unknown',
        fromDate: DateTime.parse(json['from_date'] as String),
        toDate: DateTime.parse(json['to_date'] as String),
        reason: json['reason'] as String?,
        status: json['status'] as String? ?? 'pending',
      );
}

class VacationNotifier extends Notifier<AsyncValue<List<VacationRequest>>> {
  @override
  AsyncValue<List<VacationRequest>> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    state = AsyncData([
      VacationRequest(
        id: 'vac-1',
        customerId: 'c-2',
        customerName: 'Priya Sharma',
        fromDate: DateTime.now().add(const Duration(days: 2)),
        toDate: DateTime.now().add(const Duration(days: 6)),
        reason: 'Family trip to Bangalore',
        status: 'pending',
      ),
      VacationRequest(
        id: 'vac-2',
        customerId: 'c-4',
        customerName: 'Deepa Patel',
        fromDate: DateTime.now().subtract(const Duration(days: 10)),
        toDate: DateTime.now().subtract(const Duration(days: 7)),
        reason: 'Out of town',
        status: 'approved',
      ),
    ]);

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    final vendorId = SupabaseService.currentUserId;
    if (vendorId == null) {
      state = const AsyncData([]);
      return;
    }
    try {
      final res = await SupabaseService.client
          .from('vacation_requests')
          .select('*, customers(full_name)')
          .eq('vendor_id', vendorId)
          .order('from_date', ascending: false);
      state = AsyncData(
          (res as List).map((e) => VacationRequest.fromJson(e)).toList());
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<void> approve(String id) async {
    final current = state.value ?? [];
    state = AsyncData(
      current.map((r) => r.id == id
          ? VacationRequest(
              id: r.id,
              customerId: r.customerId,
              customerName: r.customerName,
              fromDate: r.fromDate,
              toDate: r.toDate,
              reason: r.reason,
              status: 'approved',
            )
          : r).toList(),
    );
  }

  Future<void> reject(String id) async {
    final current = state.value ?? [];
    state = AsyncData(
      current.map((r) => r.id == id
          ? VacationRequest(
              id: r.id,
              customerId: r.customerId,
              customerName: r.customerName,
              fromDate: r.fromDate,
              toDate: r.toDate,
              reason: r.reason,
              status: 'rejected',
            )
          : r).toList(),
    );
  }
}

final vacationNotifierProvider =
    NotifierProvider<VacationNotifier, AsyncValue<List<VacationRequest>>>(
  () => VacationNotifier(),
);

class VacationModeScreen extends ConsumerWidget {
  const VacationModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vacationNotifierProvider);

    return ManagerScaffold(
      title: 'Vacation Requests',
      subtitle: 'Customer pause & holiday requests',
      titleIcon: Icons.beach_access_rounded,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF3D2314)),
          onPressed: () => ref.invalidate(vacationNotifierProvider),
        ),
      ],
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.error)),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.beach_access_outlined,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No vacation requests',
                      style: AppTypography.textTheme.titleMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          final pending =
              requests.where((r) => r.status == 'pending').toList();
          final others =
              requests.where((r) => r.status != 'pending').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                Text('Pending Approval',
                    style: AppTypography.textTheme.titleMedium
                        ?.copyWith(color: AppColors.warning)),
                const SizedBox(height: 8),
                ...pending.map((r) => _VacationCard(
                      request: r,
                      onApprove: () => ref
                          .read(vacationNotifierProvider.notifier)
                          .approve(r.id),
                      onReject: () => ref
                          .read(vacationNotifierProvider.notifier)
                          .reject(r.id),
                    )),
                const SizedBox(height: 16),
              ],
              if (others.isNotEmpty) ...[
                Text('Past Requests',
                    style: AppTypography.textTheme.titleMedium
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                ...others.map((r) => _VacationCard(request: r)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _VacationCard extends StatelessWidget {
  final VacationRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _VacationCard({
    required this.request,
    this.onApprove,
    this.onReject,
  });

  Color get _statusColor {
    switch (request.status) {
      case 'approved':
        return AppColors.secondary;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.customerName,
                        style: AppTypography.textTheme.titleSmall),
                    Text(
                      '${fmt.format(request.fromDate)} — ${fmt.format(request.toDate)}',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: AppTypography.textTheme.labelSmall
                      ?.copyWith(color: _statusColor),
                ),
              ),
            ],
          ),
          if (onApprove != null || onReject != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (onReject != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(
                              color: AppColors.error)),
                      child: const Text('Reject'),
                    ),
                  ),
                if (onApprove != null && onReject != null)
                  const SizedBox(width: 8),
                if (onApprove != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      child: const Text('Approve'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
