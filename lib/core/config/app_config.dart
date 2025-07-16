class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://your-project.supabase.co'; // Replace with your Supabase URL
  static const String supabaseAnonKey = 'your-anon-key'; // Replace with your Supabase anon key
  
  // Stripe Configuration
  static const String stripePublishableKey = 'pk_test_your_publishable_key'; // Replace with your Stripe publishable key
  static const String stripeSecretKey = 'sk_test_your_secret_key'; // Replace with your Stripe secret key
  
  // App Configuration
  static const String appName = 'CrowdFund';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'YOUR_API_BASE_URL'; // Replace with your API base URL
  
  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
  
  // Campaign Configuration
  static const int minCampaignDuration = 7; // days
  static const int maxCampaignDuration = 365; // days
  static const double minCampaignGoal = 100.0;
  static const double maxCampaignGoal = 1000000.0;
  
  // Verification Configuration
  static const int verificationTimeoutDays = 30;
  
  // Pagination
  static const int pageSize = 20;
}
