import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';

class ApproveAccessScreen extends StatefulWidget {
  const ApproveAccessScreen({super.key});

  @override
  State<ApproveAccessScreen> createState() => _ApproveAccessScreenState();
}

class _ApproveAccessScreenState extends State<ApproveAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String _role = AppConstants.roleMember;

  Box<UserModel> get _userBox => Hive.box<UserModel>(HiveBoxes.users);

  // UserRepository get _userRepo => getIt.get<UserRepository>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _addUser() async {
    if (!_formKey.currentState!.validate()) return;
    // final email = _normalizeEmail(_emailCtrl.text);
    // final user = UserModel(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   email: email,
    //   name: _nameCtrl.text.trim().isEmpty
    //       ? 'New Member'
    //       : _nameCtrl.text.trim(),
    //   role: _role,
    //   joinDate: DateTime.now(),
    // );
    try {
      // await _userRepo.createUser(user);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('userAdded'.tr())),
      );
      _emailCtrl.clear();
      _nameCtrl.clear();
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('failedToAddUser: $e'.tr())));
    }
  }

  // String _normalizeEmail(String input) {
  //   return input.trim().toLowerCase();
  // }

  void _removeAt(int index) async {
    final users = _userBox.values.toList().cast<UserModel>();
    if (index < 0 || index >= users.length) return;
    // final id = users[index].id;
    try {
      // await _userRepo.deleteUser(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('userRemoved'.tr()),
      ));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('failedToDeleteUser: $e'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = _userBox.values.toList().cast<UserModel>();
    return Scaffold(
      appBar: AppBar(title:  Text('approveAccess'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration:  InputDecoration(labelText: 'email'.tr()),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'enterEmail'.tr();
                      final email = v.trim();
                      final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                      if (!emailRegex.hasMatch(email)) {
                        return 'enterValidEmail'.tr();
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration:  InputDecoration(
                      labelText: 'name(Optional)'.tr(),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    items: AppConstants.roles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _role = v ?? AppConstants.roleMember),
                    decoration:  InputDecoration(labelText: 'role'.tr()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addUser,
                        icon: const Icon(Icons.check),
                        label:  Text('approveOrAdd'.tr()),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _emailCtrl.clear();
                          _nameCtrl.clear();
                        },
                        icon: const Icon(Icons.clear),
                        label:  Text('clear'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
             Text(
              'authorizedUsers'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: users.isEmpty
                  ?  Center(child: Text('noAuthorizedUsersYet'.tr()))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, i) {
                        final u = users[i];
                        return ListTile(
                          title: Text(u.name),
                          subtitle: Text(u.email),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () => _removeAt(i),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
