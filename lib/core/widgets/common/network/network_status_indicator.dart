import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/widgets/common/network/sync_cubit.dart';

class NetworkStatusIndicator extends StatefulWidget {
  const NetworkStatusIndicator({super.key});

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _controller.addListener(() {
      final newDotCount = (_controller.value * 4).floor();
      if (newDotCount != _dotCount) {
        setState(() => _dotCount = newDotCount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncStatus = context.watch<SyncCubit>().state;

    String label;
    Color textColor = Colors.white;

    switch (syncStatus) {
      case SyncStatus.waiting:
        label = "Waiting for network";
        textColor = Colors.white70; // Dim the text when offline
        break;
      case SyncStatus.updating:
        label = "Updating";
        break;
      case SyncStatus.synced:
      case SyncStatus.idle:
        return const Icon(
          Icons.cloud_done_rounded,
          color: Colors.greenAccent,
          size: 16,
        );
      case SyncStatus.error:
        label = "Sync Error";
        textColor = Colors.redAccent;
        break;
    }

    String dots = "." * (_dotCount % 4);

    return Text(
      "$label$dots",
      style: TextStyle(
        fontSize: 12,
        color: textColor,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
