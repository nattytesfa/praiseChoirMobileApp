import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import '../cubit/admin_cubit.dart';

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().loadAdminStats();
  }

  void _addNewMember() {
    // Navigate to add member screen
    // This would open a form to add new choir members
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Management')),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminStatsLoaded) {
            return _buildMemberList(state.members);
          } else if (state is AdminError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No member data available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMember,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildMemberList(List<UserModel> members) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return ListTile(
          leading: CircleAvatar(child: Text(member.name[0].toUpperCase())),
          title: Text(member.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.email),
              Text('Role: ${member.role}'),
              Text('Joined: ${_formatDate(member.joinDate)}'),
              if (!member.isActive)
                const Text(
                  'INACTIVE',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _handleMemberAction(value, member),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Member')),
              const PopupMenuItem(
                value: 'change_role',
                child: Text('Change Role'),
              ),
              if (member.isActive)
                const PopupMenuItem(
                  value: 'deactivate',
                  child: Text('Deactivate'),
                ),
              if (!member.isActive)
                const PopupMenuItem(value: 'activate', child: Text('Activate')),
            ],
          ),
        );
      },
    );
  }

  void _handleMemberAction(String action, UserModel member) {
    switch (action) {
      case 'change_role':
        _showRoleDialog(member);
        break;
      case 'deactivate':
        context.read<AdminCubit>().deactivateMember(member.id);
        break;
      case 'activate':
        // Implement activate functionality
        break;
      case 'edit':
        // Navigate to edit member screen
        break;
    }
  }

  void _showRoleDialog(UserModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role for ${member.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.roles
              .map(
                (role) => ListTile(
                  title: Text(role),
                  trailing: member.role == role
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    context.read<AdminCubit>().updateMemberRole(
                      member.id,
                      role,
                    );
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
