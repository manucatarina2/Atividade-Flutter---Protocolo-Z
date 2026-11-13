import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/ranking_repository.dart';

final rankingRepositoryProvider =
    Provider<RankingRepository>((ref) => RankingRepository());

final survivorRankingProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.read(rankingRepositoryProvider).fetchSurvivorRanking(),
);

final factionRankingProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.read(rankingRepositoryProvider).fetchFactionRanking(),
);
