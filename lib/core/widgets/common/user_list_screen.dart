// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
// import 'package:praise_choir_app/features/auth/data/models/user_model.dart';

// class UserListScreen extends StatefulWidget {
//   const UserListScreen({super.key});

//   @override
//   State<UserListScreen> createState() => _UserListScreenState();
// }

// class _UserListScreenState extends State<UserListScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final repo = context.read<AuthRepository>();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Choir Members')),
//       body: FutureBuilder<List<UserModel>>(
//         future: repo.getAllUsers(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No members found.'));
//           }

//           final users = snapshot.data!;

//           return ListView.builder(
//             itemCount: users.length,
//             itemBuilder: (context, index) {
//               final user = users[index];
//               final isAdmin = user.role == 'admin';

//               return ListTile(
//                 leading: CircleAvatar(child: Text(user.name[0])),
//                 title: Text(user.name),
//                 subtitle: Text(user.role.toUpperCase()),
//                 trailing: PopupMenuButton<String>(
//                   onSelected: (value) async {
//                     try {
//                       await repo.updateUserRole(user.id, value);
//                       setState(() {}); // Refresh list
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Role updated to $value')),
//                       );
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(e.toString())),
//                       );
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(value: 'member', child: Text('Make Member')),
//                     const PopupMenuItem(value: 'admin', child: Text('Make Leader')),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AuthRepository>();
    // Inside UserListScreen build method
    final authState = context.watch<AuthCubit>().state;

    if (authState is AuthAuthenticated && authState.user.role != 'admin') {
      return const Scaffold(
        body: Center(child: Text("Access Denied: Leaders Only")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Choir Members')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search members...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: repo.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users =
                    snapshot.data
                        ?.where(
                          (u) => u.name.toLowerCase().contains(searchQuery),
                        )
                        .toList() ??
                    [];

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isLeader = user.role == 'admin';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isLeader
                              ? Colors.red[50]
                              : Colors.blue[50],
                          child: Text(
                            user.name[0],
                            style: TextStyle(
                              color: isLeader ? Colors.red : Colors.blue,
                            ),
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(isLeader ? "Choir Leader" : "Member"),
                        trailing: _buildRoleMenu(context, repo, user),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleMenu(
    BuildContext context,
    AuthRepository repo,
    UserModel user,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        await repo.updateUserRole(user.id, value);
        setState(() {}); // Refresh the list
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'member', child: Text('Set as Member')),
        const PopupMenuItem(value: 'admin', child: Text('Set as Leader')),
      ],
    );
  }
}
