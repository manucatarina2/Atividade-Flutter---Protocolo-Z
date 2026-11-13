import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/faction.dart';
import '../../repositories/faction_repository.dart';

final factionRepositoryProvider = Provider((ref) => FactionRepository());

final factionsProvider = FutureProvider.autoDispose<List<Faction>>((ref) async {
  return ref.watch(factionRepositoryProvider).fetchFactions();
});
