import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/widgets/common/network/network_cubit.dart';

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
    final networkStatus = context.watch<NetworkCubit>().state;
    bool hasInternet = networkStatus == NetworkStatus.connected;
    String label = hasInternet ? "Updating" : "Waiting for network";
    String dots = "." * (_dotCount % 4);

    return Text(
      "$label$dots",
      style: const TextStyle(
        fontSize: 13,
        color: Colors.white,
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
