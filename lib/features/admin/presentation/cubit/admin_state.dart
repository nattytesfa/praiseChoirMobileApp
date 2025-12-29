import 'package:equatable/equatable.dart';
import 'package:praise_choir_app/features/admin/data/models/admin_stats_model.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminStatsLoaded extends AdminState {
  final AdminStatsModel stats;
  final List<UserModel> members;
  final int amharicSongsCount;
  final int kembatgnaSongsCount;

  const AdminStatsLoaded(
    this.stats,
    this.members, {
    this.amharicSongsCount = 0,
    this.kembatgnaSongsCount = 0,
  });
  int get pendingCount =>
      members.where((u) => u.approvalStatus == 'pending').length;

  @override
  List<Object> get props => [
    stats,
    members,
    amharicSongsCount,
    kembatgnaSongsCount,
  ];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}

class MemberUpdated extends AdminState {
  final UserModel member;

  const MemberUpdated(this.member);

  @override
  List<Object> get props => [member];
}

class SystemHealthChecked extends AdminStatsLoaded {
  final Map<String, dynamic> healthStatus;

  const SystemHealthChecked(
    this.healthStatus,
    super.stats,
    super.members, {
    super.amharicSongsCount,
    super.kembatgnaSongsCount,
  });

  @override
  List<Object> get props => [
    healthStatus,
    stats,
    members,
    amharicSongsCount,
    kembatgnaSongsCount,
  ];
}
