import 'package:flutter/material.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';

class MemberManagementCard extends StatelessWidget {
  final List<UserModel> members;
  final Function(String, String) onRoleChanged;
  final Function(String) onMemberDeactivated;

  const MemberManagementCard({
    super.key,
    required this.members,
    required this.onRoleChanged,
    required this.onMemberDeactivated,
  });

  void _showRoleDialog(BuildContext context, UserModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoleOption(
              context,
              member,
              'Leader',
              AppConstants.roleLeader,
            ),
            _buildRoleOption(
              context,
              member,
              'Atigni Group',
              AppConstants.roleSongwriter,
            ),
            _buildRoleOption(
              context,
              member,
              'Prayer Group',
              AppConstants.rolePrayerGroup,
            ),
            _buildRoleOption(
              context,
              member,
              'Member',
              AppConstants.roleMember,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    UserModel member,
    String displayName,
    String roleValue,
  ) {
    return ListTile(
      title: Text(displayName),
      trailing: member.role == roleValue
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        Navigator.pop(context);
        onRoleChanged(member.id, roleValue);
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case AppConstants.roleLeader:
        return Colors.red;
      case AppConstants.roleSongwriter:
        return Colors.blue;
      case AppConstants.rolePrayerGroup:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Member Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...members.map(
              (member) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRoleColor(member.role),
                  child: Text(
                    member.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(member.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.email),
                    Text(
                      'Role: ${member.role}',
                      style: TextStyle(
                        color: _getRoleColor(member.role),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!member.isActive)
                      const Text(
                        'Inactive',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'change_role') {
                      _showRoleDialog(context, member);
                    } else if (value == 'deactivate') {
                      onMemberDeactivated(member.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'change_role',
                      child: Text('Change Role'),
                    ),
                    if (member.isActive)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Text('Deactivate Member'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
