import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import '../../data/repositories/staff_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/manager_scaffold.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key});

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(staffNotifierProvider.notifier).loadStaff());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(staffNotifierProvider);

    return ManagerScaffold(
      title: 'Staff',
      subtitle: 'Delivery staff management',
      titleIcon: Icons.people_rounded,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.person_add_outlined),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Could not load staff',
                  style: AppTypography.textTheme.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(staffNotifierProvider.notifier).loadStaff(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (staffList) {
          if (staffList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_outlined,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No staff members yet',
                      style: AppTypography.textTheme.titleMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: staffList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _StaffCard(
              staff: staffList[i],
              onRemove: () => ref
                  .read(staffNotifierProvider.notifier)
                  .removeStaff(staffList[i].id),
            ),
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passcodeCtrl = TextEditingController();
    String role = 'delivery';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
              Text('Add Staff Member',
                  style: AppTypography.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passcodeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                    labelText: 'Passcode (4 digits)'),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: role,
                decoration:
                    const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(
                      value: 'delivery', child: Text('Delivery')),
                  DropdownMenuItem(
                      value: 'helper', child: Text('Helper')),
                ],
                onChanged: (v) =>
                    setModalState(() => role = v ?? 'delivery'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final staff = StaffModel(
                      id: '',
                      vendorId: '',
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      role: role,
                      passcode: passcodeCtrl.text.trim(),
                      isActive: true,
                      createdAt: DateTime.now(),
                    );
                    ref
                        .read(staffNotifierProvider.notifier)
                        .addStaff(staff);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Staff'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onRemove;

  const _StaffCard({required this.staff, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                staff.name.isNotEmpty
                    ? staff.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.name,
                    style: AppTypography.textTheme.titleSmall),
                Text(
                  '${staff.phone} · ${staff.role}',
                  style: AppTypography.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
