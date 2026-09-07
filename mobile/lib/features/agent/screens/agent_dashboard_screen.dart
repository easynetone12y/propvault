import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/property_card.dart';
import 'add_property_screen.dart';
import '../../leads/screens/leads_screen.dart';
import '../../subscription/screens/subscription_screen.dart';
import '../../properties/screens/property_detail_screen.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});
  @override State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  int _navIndex = 0;
  Map<String, dynamic>? _stats;
  List<dynamic> _myProperties = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiClient.instance.get('/agents/me/stats'),
        ApiClient.instance.get('/properties/search', queryParameters: {'page': 0, 'size': 10}),
      ]);
      setState(() {
        _stats = results[0].data;
        _myProperties = results[1].data['content'] ?? [];
        _loading = false;
      });
    } catch (e) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _DashboardHome(stats: _stats, properties: _myProperties, loading: _loading, onRefresh: _loadData),
      const LeadsScreen(),
      const SubscriptionScreen(),
    ];

    return Scaffold(
      body: screens[_navIndex],
      floatingActionButton: _navIndex == 0 ? FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
          if (added == true) _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
        backgroundColor: AppTheme.primary,
      ) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Leads'),
          NavigationDestination(icon: Icon(Icons.card_membership_outlined), selectedIcon: Icon(Icons.card_membership), label: 'Plan'),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final List<dynamic> properties;
  final bool loading;
  final VoidCallback onRefresh;
  const _DashboardHome({required this.stats, required this.properties, required this.loading, required this.onRefresh});

  String _fmt(num? n) => n == null ? '—' : NumberFormat.compact().format(n);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Agent Dashboard', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text(stats?['companyName'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: ListView(padding: const EdgeInsets.all(16), children: [

              // Subscription alert
              if (stats?['subscriptionStatus'] == 'TRIAL')
                _alert(context, '🎁 You are on a 14-day free trial. Upgrade to keep your listings live.', AppTheme.warning, () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()))),
              if (stats?['subscriptionStatus'] == 'PAST_DUE')
                _alert(context, '⚠️ Payment overdue. Update your billing to avoid listing suspension.', AppTheme.danger, () {}),

              // Stats grid
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.0, crossAxisSpacing: 10, mainAxisSpacing: 10,
                children: [
                  _statCard('Active Listings', '${stats?['activeListings'] ?? 0}', Icons.home_outlined, AppTheme.primary,
                    '${stats?['listingsUsed'] ?? 0} / ${stats?['maxListings'] == -1 ? '∞' : stats?['maxListings'] ?? '-'} used'),
                  _statCard('New Leads', '${stats?['newLeads'] ?? 0}', Icons.person_add_outlined, AppTheme.success, 'This month'),
                  _statCard('Total Views', _fmt(stats?['totalViews']), Icons.visibility_outlined, AppTheme.warning, 'All time'),
                  _statCard('Featured Slots', '${stats?['featuredUsed'] ?? 0}/${stats?['maxFeatured'] ?? 0}',
                    Icons.star_outline, const Color(0xFF7C3AED), 'Active'),
                ],
              ),

              // Plan usage bar
              if (stats != null) ...[
                const SizedBox(height: 20),
                _PlanUsageCard(stats: stats!),
              ],

              // My properties
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('My Properties', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ]),

              if (properties.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: const Column(children: [
                    Icon(Icons.home_outlined, size: 48, color: Color(0xFFD1D5DB)),
                    SizedBox(height: 12),
                    Text('No properties yet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    SizedBox(height: 4),
                    Text('Tap the + button to add your first listing', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                  ]),
                )
              else
                ...properties.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PropertyListItem(property: p, onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(propertyId: p['id'])))),
                )),
            ]),
          ),
    );
  }

  Widget _alert(BuildContext ctx, String msg, Color color, VoidCallback onAction) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withOpacity(.08),
      borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(.3))),
    child: Row(children: [
      Expanded(child: Text(msg, style: TextStyle(color: color, fontSize: 13))),
      TextButton(onPressed: onAction, child: Text('Upgrade', style: TextStyle(color: color, fontWeight: FontWeight.w700))),
    ]));

  Widget _statCard(String label, String value, IconData icon, Color color, String sub) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(
          color: color.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color)),
        const Spacer(),
        Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
      ]),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
    ]));
}

class _PlanUsageCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _PlanUsageCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final used = (stats['listingsUsed'] as num?)?.toDouble() ?? 0;
    final max  = (stats['maxListings']  as num?) == -1 ? null : (stats['maxListings'] as num?)?.toDouble() ?? 1;
    final pct  = max == null ? 0.0 : (used / max).clamp(0.0, 1.0);
    final plan = stats['subscriptionPlan'] ?? 'Basic';
    final status = stats['subscriptionStatus'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF185FA5), Color(0xFF0C447C)]),
        borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(plan, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(10)),
            child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
          const Spacer(),
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
            icon: const Icon(Icons.upgrade, size: 16, color: Colors.white),
            label: const Text('Upgrade', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Listings: ${used.toInt()} / ${max == null ? "∞" : max.toInt()}',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text('Renews: ${stats['renewalDate'] ?? '—'}',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.toDouble(), minHeight: 6,
            backgroundColor: Colors.white.withOpacity(.2),
            valueColor: AlwaysStoppedAnimation<Color>(pct > 0.8 ? Colors.orange : Colors.white))),
      ]));
  }
}

class _PropertyListItem extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;
  const _PropertyListItem({required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = property['status'] as String? ?? '';
    final statusColors = {
      'APPROVED': AppTheme.success, 'PENDING_REVIEW': AppTheme.warning,
      'REJECTED': AppTheme.danger, 'DRAFT': const Color(0xFF6B7280),
    };
    final c = statusColors[status] ?? const Color(0xFF6B7280);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.home_outlined, color: AppTheme.primary, size: 28)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(property['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${property['city'] ?? ''} · ${property['purpose'] ?? ''}',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.visibility_outlined, size: 12, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 3),
              Text('${property['viewCount'] ?? 0} views', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: c.withOpacity(.1), borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.withOpacity(.3))),
              child: Text(status.replaceAll('_', ' '),
                style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600))),
            const SizedBox(height: 6),
            Row(children: [
              _iconBtn(Icons.edit_outlined, () {}),
              const SizedBox(width: 4),
              _iconBtn(Icons.delete_outline, () {}),
            ]),
          ]),
        ]),
      ));
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 14, color: const Color(0xFF6B7280))));
}
