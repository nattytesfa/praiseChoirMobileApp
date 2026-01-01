import 'package:easy_localization/easy_localization.dart';
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
      appBar: AppBar(
        title: Text('memberManagement'.tr()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'searchMembers'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: Colors.black,
                filled: true,
              ),
              onChanged: (value) {},
            ),
          ),
        ),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminStatsLoaded) {
            return _buildMemberList(state.members);
          } else if (state is AdminError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('noMemberDataAvailable'.tr()));
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(child: Text(member.name[0].toUpperCase())),
          title: Text(member.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.email),
              Text('roleLabel'.tr(args: [member.role])),
              Text('joinedLabel'.tr(args: [_formatDate(member.joinDate)])),
              if (!member.isActive)
                Text(
                  'inactiveMembers'.tr(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _handleMemberAction(value, member),
            itemBuilder: (context) => [
              // const PopupMenuItem(value: 'edit', child: Text('Edit Member')),
              PopupMenuItem(
                value: 'change_role',
                child: Text('changeRole'.tr()),
              ),

              !member.isActive
                  ? PopupMenuItem(
                      value: 'activate',
                      child: Text(
                        'activate'.tr(),
                        style: TextStyle(color: Colors.green),
                      ),
                    )
                  : PopupMenuItem(
                      value: 'deactivate',
                      child: Text(
                        'deactivate'.tr(),
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
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
        _showConfirmDialog(
          title: "deactivateMember".tr(),
          content: "areYouSureYouWantToDisable".tr(args: [member.name]),
          onConfirm: () =>
              context.read<AdminCubit>().deactivateMember(member.id),
        );
        break;
      case 'activate':
        _showConfirmDialog(
          title: "activateMember".tr(),
          content: "restoreAppAccessFor".tr(args: [member.name]),
          onConfirm: () => context.read<AdminCubit>().activateMember(member.id),
        );
        break;
    }
  }

  // Helper for quick confirmations
  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: Text("confirm".tr()),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(UserModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('changeRoleFor'.tr(args: [member.name])),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.roles
              .map(
                (role) => ListTile(
                  title: Text(role.tr()),
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
