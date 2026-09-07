import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/properties/screens/property_search_screen.dart';
import '../../features/properties/screens/property_detail_screen.dart';
import '../../features/agent/screens/agent_dashboard_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';

class AppRouter {
  static const _storage = FlutterSecureStorage();

  static Future<Widget> getInitialScreen() async {
    final token = await _storage.read(key: 'access_token');
    final role  = await _storage.read(key: 'user_role');
    if (token == null) return const LoginScreen();
    return switch (role) {
      'SUPER_ADMIN' => const AdminDashboardScreen(),
      'AGENT'       => const AgentDashboardScreen(),
      _             => const PropertySearchScreen(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      '/login'      => MaterialPageRoute(builder: (_) => const LoginScreen()),
      '/search'     => MaterialPageRoute(builder: (_) => const PropertySearchScreen()),
      '/agent'      => MaterialPageRoute(builder: (_) => const AgentDashboardScreen()),
      '/admin'      => MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      '/property'   => MaterialPageRoute(builder: (_) =>
          PropertyDetailScreen(propertyId: settings.arguments as String)),
      _             => MaterialPageRoute(builder: (_) => const LoginScreen()),
    };
  }
}
