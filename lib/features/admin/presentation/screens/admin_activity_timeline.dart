import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/features/admin/data/activity_repository.dart';
import 'package:praise_choir_app/features/admin/data/models/activity_event.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/activity_cubit.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/payment/data/payment_repository.dart';

class AdminActivityTimeline extends StatelessWidget {
  const AdminActivityTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityCubit(
        ActivityRepository(
          context.read<AuthRepository>(),
          context.read<PaymentRepository>(),
        ),
      )..loadActivities(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('activityLog'.tr()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'clearHistory'.tr(),
                  onPressed: () {
                    // Capture the cubit from the context that has the provider
                    final cubit = context.read<ActivityCubit>();

                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text('clearHistory'.tr()),
                        content: Text('clearActivityHistoryConfirm'.tr()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text('cancel'.tr()),
                          ),
                          TextButton(
                            onPressed: () {
                              cubit.clearHistory();
                              Navigator.pop(dialogContext);
                            },
                            child: Text('clear'.tr()),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ActivityCubit, ActivityState>(
          builder: (context, state) {
            if (state is ActivityLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ActivityError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is ActivityLoaded) {
              final activities = state.activities;
              if (activities.isEmpty) {
                return const Center(child: Text('No recent activities found.'));
              }
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Timeline.tileBuilder(
                  theme: TimelineThemeData(
                    nodePosition: 0,
                    color: const Color(0xff989898),
                    indicatorTheme: const IndicatorThemeData(
                      position: 0,
                      size: 20.0,
                    ),
                    connectorTheme: const ConnectorThemeData(thickness: 2.5),
                  ),
                  builder: TimelineTileBuilder.connected(
                    connectionDirection: ConnectionDirection.before,
                    itemCount: activities.length,
                    contentsBuilder: (context, index) {
                      final event = activities[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 20.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        event.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'MMM d, h:mm a',
                                      ).format(event.timestamp),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  event.description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (event.user != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.user!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    indicatorBuilder: (context, index) {
                      final event = activities[index];
                      return DotIndicator(
                        color: _getColorForType(event.type),
                        child: Icon(
                          _getIconForType(event.type),
                          size: 12.0,
                          color: Colors.white,
                        ),
                      );
                    },
                    connectorBuilder: (context, index, type) {
                      return SolidLineConnector(color: const Color(0xffd3d3d3));
                    },
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Color _getColorForType(ActivityType type) {
    switch (type) {
      case ActivityType.userRegistration:
        return Colors.green;
      case ActivityType.paymentReceived:
        return Colors.purple;
      case ActivityType.songAdded:
        return Colors.blue;
      case ActivityType.systemUpdate:
        return Colors.orange;
      case ActivityType.alert:
        return Colors.red;
      case ActivityType.chatActivity:
        return Colors.teal;
      case ActivityType.announcement:
        return Colors.deepOrange;
      case ActivityType.userStatusChange:
        return Colors.amber;
      case ActivityType.songDeleted:
        return Colors.red;
      case ActivityType.songEdited:
        return Colors.blueGrey;
    }
  }

  IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.userRegistration:
        return Icons.person_add;
      case ActivityType.paymentReceived:
        return Icons.payment;
      case ActivityType.songAdded:
        return Icons.music_note;
      case ActivityType.systemUpdate:
        return Icons.system_update;
      case ActivityType.alert:
        return Icons.warning;
      case ActivityType.chatActivity:
        return Icons.chat;
      case ActivityType.announcement:
        return Icons.campaign;
      case ActivityType.userStatusChange:
        return Icons.manage_accounts;
      case ActivityType.songDeleted:
        return Icons.delete_forever;
      case ActivityType.songEdited:
        return Icons.edit_note;
    }
  }
}
