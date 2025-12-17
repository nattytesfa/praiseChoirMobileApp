class StorageConstants {
  // Hive box names
  static const String boxUsers = 'users';
  static const String boxSongs = 'songs';
  static const String boxPayments = 'payments';
  static const String boxChats = 'chats';
  static const String boxMessages = 'messages';
  static const String boxEvents = 'events';
  static const String boxGallery = 'gallery';
  static const String boxSettings = 'settings';
  static const String boxCache = 'cache';

  // Hive type IDs (must be unique across the app)
  static const int typeIdUser = 0;
  static const int typeIdSong = 1;
  static const int typeIdSongVersion = 2;
  static const int typeIdRecordingNote = 3;
  static const int typeIdPayment = 4;
  static const int typeIdPaymentStatus = 5;
  static const int typeIdChat = 6;
  static const int typeIdMessage = 7;
  static const int typeIdMessageType = 8;
  static const int typeIdChatType = 9;
  static const int typeIdEvent = 10;
  static const int typeIdAnnouncement = 11;
  static const int typeIdPoll = 12;
  static const int typeIdPollOption = 13;
  static const int typeIdEventType = 14;
  static const int typeIdAdminStats = 15;

  // Storage paths
  static const String audioDirectory = 'audio';
  static const String imagesDirectory = 'images';
  static const String documentsDirectory = 'documents';
  static const String backupsDirectory = 'backups';
  static const String tempDirectory = 'temp';

  // File extensions
  static const String extensionAudio = '.m4a';
  static const String extensionImage = '.jpg';
  static const String extensionBackup = '.backup';
  static const String extensionLog = '.log';

  // Storage limits
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxAudioStorage = 500 * 1024 * 1024; // 500MB
  static const int maxImageStorage = 200 * 1024 * 1024; // 200MB
  static const int maxBackupStorage = 100 * 1024 * 1024; // 100MB

  // Cache durations
  static const Duration cacheDurationShort = Duration(minutes: 30);
  static const Duration cacheDurationMedium = Duration(hours: 2);
  static const Duration cacheDurationLong = Duration(hours: 24);
  static const Duration cacheDurationVeryLong = Duration(days: 7);

  // Cache keys
  static const String cacheKeySongs = 'songs_cache';
  static const String cacheKeyPayments = 'payments_cache';
  static const String cacheKeyEvents = 'events_cache';
  static const String cacheKeyMembers = 'members_cache';
  static const String cacheKeyAdminStats = 'admin_stats_cache';

  // Backup settings
  static const int backupRetentionDays = 30;
  static const int maxBackupFiles = 10;
  static const bool autoBackupEnabled = true;
  static const Duration autoBackupInterval = Duration(days: 7);

  // Encryption (if needed)
  static const String encryptionKey =
      'your_encryption_key_here'; // In production, use secure storage
  static const bool enableEncryption = false;

  // Sync settings
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxSyncRetries = 3;
  static const Duration syncRetryDelay = Duration(seconds: 5);

  // File size limits
  static const int maxFileSizeAudio = 10 * 1024 * 1024; // 10MB
  static const int maxFileSizeImage = 5 * 1024 * 1024; // 5MB
  static const int maxFileSizeDocument = 2 * 1024 * 1024; // 2MB

  // Compression settings
  static const int imageQuality = 80;
  static const int audioBitrate = 128000; // 128kbps

  // Supported file format lists (used by file picker)
  // Note: these should be provided without leading dots for FilePicker
  static const List<String> supportedAudioFormats = [
    'm4a',
    'mp3',
    'wav',
    'aac',
  ];
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const List<String> supportedVideoFormats = [
    'mp4',
    'mov',
    'avi',
    'mkv',
  ];

  // Helper methods
  static String getAudioFilePath(String fileName) {
    return '$audioDirectory/${fileName.replaceAll(' ', '_')}$extensionAudio';
  }

  static String getImageFilePath(String fileName) {
    return '$imagesDirectory/${fileName.replaceAll(' ', '_')}$extensionImage';
  }

  static String getBackupFilePath(DateTime date) {
    final formattedDate =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return '$backupsDirectory/backup_$formattedDate$extensionBackup';
  }

  static bool isStorageLimitReached(int currentSize, String storageType) {
    switch (storageType) {
      case 'audio':
        return currentSize >= maxAudioStorage;
      case 'images':
        return currentSize >= maxImageStorage;
      case 'backup':
        return currentSize >= maxBackupStorage;
      case 'cache':
        return currentSize >= maxCacheSize;
      default:
        return false;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }
}
