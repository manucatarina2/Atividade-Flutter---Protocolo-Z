import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../models/horde_alert.dart';

final hordeAlertStreamProvider = StreamProvider<HordeAlert>((ref) {
  return SupabaseConfig.client
      .from('horde_alerts')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((data) {
        if (data.isEmpty) return null;
        return HordeAlert.fromJson(data.last);
      })
      .where((alert) => alert != null)
      .cast<HordeAlert>();
});
