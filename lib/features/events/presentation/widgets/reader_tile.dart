import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';

class ReaderTile extends StatelessWidget {
  final String userId;

  const ReaderTile({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: context.read<AuthRepository>().getUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text('Loading...'),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person_off)),
            title: Text('Unknown User'),
          );
        }

        final user = snapshot.data!;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profileImagePath != null
                ? NetworkImage(user.profileImagePath!)
                : null,
            child: user.profileImagePath == null
                ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
                : null,
          ),
          title: Text(user.name),
          subtitle: Text(user.role),
        );
      },
    );
  }
}
