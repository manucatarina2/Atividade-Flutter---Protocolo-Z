import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/horde_alert.dart';
import '../../repositories/horde_repository.dart';

final hordeRepositoryProvider = Provider((ref) => HordeRepository());

final activeAlertsProvider =
    FutureProvider.autoDispose<List<HordeAlert>>((ref) async {
  return ref.watch(hordeRepositoryProvider).fetchActiveAlerts();
});
