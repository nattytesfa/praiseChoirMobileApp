import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/admin/data/activity_repository.dart';
import 'package:praise_choir_app/features/admin/data/models/activity_event.dart';

abstract class ActivityState {}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<ActivityEvent> activities;
  ActivityLoaded(this.activities);
}

class ActivityError extends ActivityState {
  final String message;
  ActivityError(this.message);
}

class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepository _repository;

  ActivityCubit(this._repository) : super(ActivityInitial());

  Future<void> loadActivities() async {
    emit(ActivityLoading());
    try {
      final activities = await _repository.getRecentActivities();
      emit(ActivityLoaded(activities));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> clearHistory() async {
    try {
      await _repository.clearHistory();
      loadActivities();
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }
}
