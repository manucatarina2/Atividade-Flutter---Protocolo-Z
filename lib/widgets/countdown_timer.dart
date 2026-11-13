import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endsAt;
  final VoidCallback onFinished;
  final TextStyle? style;

  const CountdownTimer({
    super.key,
    required this.endsAt,
    required this.onFinished,
    this.style,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _calculateRemaining();
      }
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    if (now.isAfter(widget.endsAt)) {
      setState(() => _remaining = Duration.zero);
      _timer.cancel();
      widget.onFinished();
    } else {
      setState(() => _remaining = widget.endsAt.difference(now));
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$minutes:$seconds',
      style: widget.style ??
          const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
