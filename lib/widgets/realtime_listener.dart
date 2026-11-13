import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../state/realtime/realtime_provider.dart';

class RealtimeListener extends ConsumerStatefulWidget {
  final Widget child;
  const RealtimeListener({super.key, required this.child});

  @override
  ConsumerState<RealtimeListener> createState() => _RealtimeListenerState();
}

class _RealtimeListenerState extends ConsumerState<RealtimeListener> {
  @override
  Widget build(BuildContext context) {
    ref.listen(hordeAlertStreamProvider, (previous, next) {
      if (next.hasValue && previous?.value?.id != next.value?.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ NOVA HORDA AVISTADA!'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return widget.child;
  }
}
