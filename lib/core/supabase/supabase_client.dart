import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://tfiyqhthpnnwgnavwxsg.supabase.co';
  static const String anonKey =
      'sb_publishable_gx4_xFHlwOW-A9QEUcF7ug_1m8SiGbU';

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
