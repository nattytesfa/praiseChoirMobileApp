import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/empty_state.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../cubit/event_cubit.dart';
import '../cubit/event_state.dart';
import '../widgets/announcement_card.dart';

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
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == announcements.length - 1 ? 0 : 12,
                    ),
                    child: AnnouncementCard(
                      announcement: announcement,
                      onMarkAsRead: (announcementId) {
                        // TODO: Get current user ID from auth
                        final userId = 'current_user_id';
                        context.read<EventCubit>().markAnnouncementAsRead(
                          announcementId,
                          userId,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create announcement screen
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
