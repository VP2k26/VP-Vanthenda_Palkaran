import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/staff_repository.dart';

final staffNotifierProvider =
    NotifierProvider<StaffNotifier, AsyncValue<List<StaffModel>>>(
  StaffNotifier.new,
);

class StaffNotifier extends Notifier<AsyncValue<List<StaffModel>>> {
  @override
  AsyncValue<List<StaffModel>> build() => const AsyncData([]);

  Future<void> loadStaff() async {
    state = const AsyncLoading();
    try {
      final staff = await ref.read(staffRepositoryProvider).fetchStaff();
      state = AsyncData(staff);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addStaff(StaffModel staff) async {
    try {
      await ref.read(staffRepositoryProvider).createStaff(staff);
      await loadStaff();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deactivateStaff(String staffId) async {
    try {
      await ref.read(staffRepositoryProvider).deactivateStaff(staffId);
      await loadStaff();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> removeStaff(String staffId) async => deactivateStaff(staffId);
}
