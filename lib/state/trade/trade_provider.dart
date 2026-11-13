import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trade.dart';
import '../../repositories/trade_repository.dart';

final tradeRepositoryProvider = Provider((ref) => TradeRepository());

final myTradesProvider = FutureProvider.autoDispose<List<Trade>>((ref) async {
  return ref.watch(tradeRepositoryProvider).fetchMyTrades();
});
