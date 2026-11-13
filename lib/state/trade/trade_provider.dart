import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trade.dart';
import '../../models/profile.dart';
import '../../repositories/trade_repository.dart';

final tradeRepositoryProvider = Provider((ref) => TradeRepository());

final myTradesProvider = FutureProvider.autoDispose<List<Trade>>((ref) async {
  return ref.watch(tradeRepositoryProvider).fetchMyTrades();
});

final availablePlayersProvider =
    FutureProvider.autoDispose<List<Profile>>((ref) async {
  return ref.watch(tradeRepositoryProvider).fetchOtherPlayers();
});
