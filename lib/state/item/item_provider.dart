import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_client.dart';
import '../../models/item.dart';

final itemCatalogProvider = FutureProvider.autoDispose<List<Item>>((ref) async {
  final data = await SupabaseConfig.client.from('items').select();
  return (data as List).map((e) => Item.fromJson(e)).toList();
});
