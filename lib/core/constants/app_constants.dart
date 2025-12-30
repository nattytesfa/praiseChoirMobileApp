class AppConstants {
  static const String appName = 'Choir App';
  static const String appVersion = '1.0.0';

  // Payment constants
  static const double monthlyPaymentAmount = 10.0;
  static const int paymentDueDay = 1; // 1st of every month

  // Role constants
  static const String roleLeader = 'admin';
  static const String roleUser = 'user';
  static const String roleSongwriter = 'songwriter';
  static const String roleMember = 'member';
  static const String rolePrayerGroup = 'prayer_group';
  // Grouped role list for iterating in UI
  static const List<String> roles = [
    roleLeader,
    roleSongwriter,
    roleMember,
    rolePrayerGroup,
  ];

  // Language constants
  static const String languageAmharic = 'am';
  static const String languageEnglish = 'en';
  static const String languageKembatigna = 'kembatigna';

  // Song tags
  static const String tagNew = 'new';
  static const String tagFavorite = 'favorite';
  static const String tagThisRound = 'this_round';
}

class HiveBoxes {
  static const String users = 'users';
  static const String songs = 'songs';
  static const String payments = 'payments';
  static const String settings = 'app_settings';
  static const String events = 'events';
  static const String chat = 'chat';
}
