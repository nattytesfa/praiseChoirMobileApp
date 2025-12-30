import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/events/event_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/empty_state.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../cubit/event_cubit.dart';
import '../cubit/event_state.dart';
import '../widgets/announcement_card.dart';
import '../widgets/reader_tile.dart';

class AnnouncementBoard extends StatelessWidget {
  const AnnouncementBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<EventCubit, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const LoadingIndicator();
          }

          if (state is EventError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<EventCubit>().loadEvents(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is EventLoaded) {
            final announcements = state.announcements;

            if (announcements.isEmpty) {
              return const EmptyState(
                icon: Icons.announcement,
                title: 'No Announcements',
                message: 'There are no announcements at the moment.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<EventCubit>().loadEvents();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  final authState = context.read<AuthCubit>().state;
                  final currentUserId = authState is AuthAuthenticated
                      ? authState.user.id
                      : '';
                  final isAdmin =
                      authState is AuthAuthenticated &&
                      authState.user.role == AppConstants.roleLeader;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == announcements.length - 1 ? 0 : 12,
                    ),
                    child: AnnouncementCard(
                      announcement: announcement,
                      currentUserId: currentUserId,
                      isAdmin: isAdmin,
                      onMarkAsRead: (announcementId) {
                        if (currentUserId.isNotEmpty) {
                          context.read<EventCubit>().markAnnouncementAsRead(
                            announcementId,
                            currentUserId,
                          );
                        }
                      },
                      onEdit: (announcement) {
                        Navigator.pushNamed(
                          context,
                          EventRoutes.createAnnouncement,
                          arguments: announcement,
                        );
                      },
                      onDelete: (announcementId) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Announcement'),
                            content: const Text(
                              'Are you sure you want to delete this announcement?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<EventCubit>().deleteAnnouncement(
                                    announcementId,
                                  );
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onViewReaders: (announcement) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Read By'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: announcement.readBy.isEmpty
                                  ? const Text('No one has read this yet.')
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: announcement.readBy.length,
                                      itemBuilder: (context, index) {
                                        return ReaderTile(
                                          userId: announcement.readBy[index],
                                        );
                                      },
                                    ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const LoadingIndicator();
        },
      ),
      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated &&
              state.user.role == AppConstants.roleLeader) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, EventRoutes.createAnnouncement);
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
