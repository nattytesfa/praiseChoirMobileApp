import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';
import 'package:praise_choir_app/features/events/presentation/cubit/event_cubit.dart';
import 'package:praise_choir_app/features/events/presentation/cubit/event_state.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final AnnouncementModel? announcement;
  const CreateAnnouncementScreen({super.key, this.announcement});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isUrgent = false;
  final List<String> _selectedRoles = [AppConstants.roleMember];

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      _titleController.text = widget.announcement!.title;
      _contentController.text = widget.announcement!.content;
      _isUrgent = widget.announcement!.isUrgent;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('loginToPost'.tr())));
        return;
      }

      final currentUser = authState.user;
      final announcement = AnnouncementModel(
        id:
            widget.announcement?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdBy: widget.announcement?.createdBy ?? currentUser.id,
        authorName: widget.announcement?.authorName ?? currentUser.name,
        createdAt: widget.announcement?.createdAt ?? DateTime.now(),
        isUrgent: _isUrgent,
        targetRoles: _selectedRoles,
        priority: _isUrgent ? 5 : 1,
        readBy: widget.announcement?.readBy ?? [],
      );

      if (widget.announcement != null) {
        context.read<EventCubit>().updateAnnouncement(announcement);
      } else {
        context.read<EventCubit>().createAnnouncement(announcement);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.announcement != null
              ? 'editAnnouncement'.tr()
              : 'newAnnouncement'.tr(),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<EventCubit, EventState>(
        listener: (context, state) {
          if (state is AnnouncementCreated) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('announcementPosted'.tr())));
            Navigator.pop(context);
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'title'.tr(),
                    border: const OutlineInputBorder(),
                    hintText: 'e.g., Rehearsal Cancelled',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'enterTitle'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'content'.tr(),
                    border: const OutlineInputBorder(),
                    hintText: 'Enter the details of your announcement...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'enterContent'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text('markAsUrgent'.tr()),
                  subtitle: Text('urgentDescription'.tr()),
                  value: _isUrgent,
                  onChanged: (value) {
                    setState(() {
                      _isUrgent = value;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocBuilder<EventCubit, EventState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AnnouncementCreating
                            ? null
                            : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: state is AnnouncementCreating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.announcement != null
                                    ? 'updateAnnouncement'.tr()
                                    : 'postAnnouncement'.tr(),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
