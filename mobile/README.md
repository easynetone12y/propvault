# PropVault — Mobile App (Flutter)

Flutter 3 app for Android and iOS.

## Stack

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | ^8.1.4 | State management |
| go_router | ^13.2.0 | Navigation |
| dio | ^5.4.1 | HTTP client with interceptors |
| flutter_secure_storage | ^9.0.0 | Secure token storage |
| razorpay_flutter | ^1.3.6 | Payment checkout |
| flutter_map | ^6.1.0 | Property map view |
| fl_chart | ^0.67.0 | Analytics charts |
| cached_network_image | ^3.3.1 | Property image caching |

## Structure

```
lib/
├── main.dart
├── core/
│   ├── api/api_client.dart          # Dio + JWT interceptor + refresh
│   ├── constants/app_constants.dart # API base URL, Razorpay key
│   ├── router/app_router.dart       # go_router, role-based initial route
│   ├── theme/app_theme.dart         # Material 3 + Inter font
│   └── widgets/                     # PropertyCard, PropVaultButton
└── features/
    ├── auth/screens/login_screen.dart
    ├── properties/screens/
    │   ├── property_search_screen.dart
    │   └── property_detail_screen.dart
    ├── leads/screens/
    │   ├── contact_agent_sheet.dart
    │   └── leads_screen.dart
    ├── agent/screens/
    │   ├── agent_dashboard_screen.dart
    │   └── add_property_screen.dart
    ├── subscription/screens/subscription_screen.dart
    └── admin/screens/admin_dashboard_screen.dart
```

## Running

```bash
# Prerequisites: Flutter 3.x, Android Studio or Xcode

flutter pub get

# Android
flutter run -d android

# iOS (Mac only)
flutter run -d ios

# Web
flutter run -d chrome
```

## Configuration

Edit `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String apiBaseUrl = 'http://localhost:8080/api/v1';
  static const String razorpayKeyId = 'rzp_test_xxxxxxxxxxxx';
}
```
