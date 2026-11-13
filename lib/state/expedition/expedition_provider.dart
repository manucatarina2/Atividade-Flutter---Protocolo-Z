import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expedition.dart';
import '../../models/expedition_type.dart';
import '../../repositories/expedition_repository.dart';

final expeditionRepositoryProvider = Provider((ref) => ExpeditionRepository());

final expeditionTypesProvider =
    FutureProvider.autoDispose<List<ExpeditionType>>((ref) async {
  return ref.watch(expeditionRepositoryProvider).fetchTypes();
});

final activeExpeditionProvider =
    FutureProvider.autoDispose<Expedition?>((ref) async {
  return ref.watch(expeditionRepositoryProvider).fetchActiveExpedition();
});
