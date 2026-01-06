enum ActivityType {
  userRegistration,
  paymentReceived,
  songAdded,
  systemUpdate,
  alert,
  chatActivity,
  announcement,
  userStatusChange,
}

class ActivityEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;
  final String? user;

  const ActivityEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.user,
  });
}
