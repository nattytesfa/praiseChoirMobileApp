import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  final String role;
  final double size;

  const RoleBadge({super.key, required this.role, this.size = 20.0});

  Color _getRoleColor() {
    switch (role) {
      case 'leader':
        return Colors.red;
      case 'atigni':
        return Colors.blue;
      case 'prayer_group':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRoleInitial() {
    switch (role) {
      case 'leader':
        return 'L';
      case 'atigni':
        return 'A';
      case 'prayer_group':
        return 'P';
      default:
        return 'M';
    }
  }

  String _getRoleDisplayName() {
    switch (role) {
      case 'leader':
        return 'Leader';
      case 'atigni':
        return 'Atigni';
      case 'prayer_group':
        return 'Prayer Group';
      default:
        return 'Member';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: _getRoleColor(), shape: BoxShape.circle),
      child: Tooltip(
        message: _getRoleDisplayName(),
        child: Center(
          child: Text(
            _getRoleInitial(),
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class RoleChip extends StatelessWidget {
  final String role;

  const RoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _getRoleDisplayName(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _getRoleColor(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getRoleColor() {
    switch (role) {
      case 'leader':
        return Colors.red;
      case 'atigni':
        return Colors.blue;
      case 'prayer_group':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName() {
    switch (role) {
      case 'leader':
        return 'Leader';
      case 'atigni':
        return 'Atigni Group';
      case 'prayer_group':
        return 'Prayer Group';
      default:
        return 'Member';
    }
  }
}
