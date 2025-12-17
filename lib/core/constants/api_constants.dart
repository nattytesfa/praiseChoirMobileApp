class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://your-backend-domain.com/api';
  static const String storageBaseUrl = 'https://your-storage-domain.com';

  // Authentication endpoints
  static const String login = '$baseUrl/auth/login';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String refreshToken = '$baseUrl/auth/refresh-token';
  static const String logout = '$baseUrl/auth/logout';

  // User endpoints
  static const String users = '$baseUrl/users';
  static const String userProfile = '$baseUrl/users/profile';
  static const String updateProfile = '$baseUrl/users/profile/update';

  // Song endpoints
  static const String songs = '$baseUrl/songs';
  static const String uploadSongAudio = '$baseUrl/songs/upload-audio';
  static const String searchSongs = '$baseUrl/songs/search';
  static const String songStatistics = '$baseUrl/songs/statistics';

  // Payment endpoints
  static const String payments = '$baseUrl/payments';
  static const String markPaymentPaid = '$baseUrl/payments/mark-paid';
  static const String paymentReports = '$baseUrl/payments/reports';
  static const String monthlySummary = '$baseUrl/payments/monthly-summary';

  // Chat endpoints
  static const String chats = '$baseUrl/chats';
  static const String messages = '$baseUrl/messages';
  static const String uploadMessageMedia = '$baseUrl/messages/upload-media';

  // Event endpoints
  static const String events = '$baseUrl/events';
  static const String announcements = '$baseUrl/announcements';
  static const String polls = '$baseUrl/polls';

  // Gallery endpoints
  static const String gallery = '$baseUrl/gallery';
  static const String uploadMedia = '$baseUrl/gallery/upload';

  // Admin endpoints
  static const String adminStats = '$baseUrl/admin/stats';
  static const String adminMembers = '$baseUrl/admin/members';
  static const String systemHealth = '$baseUrl/admin/health';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File upload limits
  static const int maxAudioFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageFileSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoFileSize = 20 * 1024 * 1024; // 20MB

  // Supported file types
  static const List<String> supportedAudioFormats = ['mp3', 'm4a', 'wav'];
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];
}

class ApiResponseCodes {
  static const int success = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int internalServerError = 500;
  static const int serviceUnavailable = 503;
}

class ApiErrorMessages {
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error, please try again later';
  static const String unauthorized = 'Please login again';
  static const String forbidden =
      'You do not have permission to perform this action';
  static const String notFound = 'Requested resource not found';
  static const String timeout = 'Request timeout, please check your connection';
  static const String unknownError = 'An unknown error occurred';
}
