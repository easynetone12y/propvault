import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _navIndex = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [
      const _AdminOverview(),
      const _AgentManagementTab(),
      const _PendingListingsTab(),
    ];
    return Scaffold(
      body: screens[_navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Agents'),
          NavigationDestination(icon: Icon(Icons.pending_outlined), selectedIcon: Icon(Icons.pending), label: 'Pending'),
        ],
      ),
    );
  }
}

class _AdminOverview extends StatefulWidget {
  const _AdminOverview();
  @override State<_AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<_AdminOverview> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await ApiClient.instance.get('/admin/dashboard');
      setState(() { _stats = r.data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  String _fmtCr(dynamic n) {
    final v = (n as num?)?.toDouble() ?? 0;
    if (v >= 100000) return '₹${(v/100000).toStringAsFixed(2)} L';
    return '₹${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              // MRR hero card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF185FA5), Color(0xFF0C447C)]),
                  borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Monthly Recurring Revenue', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(_fmtCr(_stats?['mrr']),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Row(children: [
                    _mrrStat('Basic', '${_stats?['basicPlanCount'] ?? 0}', '× ₹999'),
                    _mrrStat('Pro', '${_stats?['proPlanCount'] ?? 0}', '× ₹2,999'),
                    _mrrStat('Premium', '${_stats?['premiumPlanCount'] ?? 0}', '× ₹5,999'),
                  ]),
                ])),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.8,
                children: [
                  _tile('Total Agents',    '${_stats?['totalAgents'] ?? 0}',    Icons.people_outline,    AppTheme.primary),
                  _tile('Verified',        '${_stats?['verifiedAgents'] ?? 0}', Icons.verified_outlined, AppTheme.success),
                  _tile('Pending Agents',  '${_stats?['pendingAgents'] ?? 0}',  Icons.pending_outlined,  AppTheme.warning),
                  _tile('Active Listings', '${_stats?['activeListings'] ?? 0}', Icons.home_outlined,     const Color(0xFF7C3AED)),
                  _tile('Pending Review',  '${_stats?['pendingListings'] ?? 0}',Icons.rate_review_outlined, AppTheme.warning),
                  _tile('Leads / Month',   '${_stats?['leadsThisMonth'] ?? 0}', Icons.person_add_outlined, AppTheme.accent),
                ],
              ),
            ])));
  }

  Widget _mrrStat(String plan, String count, String price) => Expanded(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(plan, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      Text(count, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      Text(price, style: const TextStyle(color: Colors.white60, fontSize: 10)),
    ]));

  Widget _tile(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
        color: color.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: color)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      ]),
    ]));
}

class _AgentManagementTab extends StatefulWidget {
  const _AgentManagementTab();
  @override State<_AgentManagementTab> createState() => _AgentManagementTabState();
}

class _AgentManagementTabState extends State<_AgentManagementTab> {
  List<dynamic> _agents = [];
  bool _loading = true;
  String _filter = 'all'; // all, verified, pending

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final params = _filter != 'all' ? {'status': _filter} : <String, dynamic>{};
      final r = await ApiClient.instance.get('/admin/agents', queryParameters: params);
      setState(() { _agents = r.data['content'] ?? []; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _approve(String id) async {
    try {
      await ApiClient.instance.patch('/admin/agents/$id/approve');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agent approved ✅'), backgroundColor: AppTheme.success));
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Agent Management'),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(48),
        child: Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(children: [
            _chip('All', 'all'), const SizedBox(width: 8),
            _chip('Verified', 'verified'), const SizedBox(width: 8),
            _chip('Pending', 'pending'),
          ])))),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _agents.length,
          itemBuilder: (_, i) {
            final a = _agents[i];
            final pending = a['verified'] != true;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text((a['companyName'] as String? ?? 'A')[0],
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700))),
                title: Row(children: [
                  Text(a['companyName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (!pending) const SizedBox(width: 4),
                  if (!pending) const Icon(Icons.verified, size: 14, color: AppTheme.primary),
                ]),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${a['name'] ?? ''} · ${a['city'] ?? ''}',
                    style: const TextStyle(fontSize: 12)),
                  Text('${a['subscriptionPlan'] ?? 'No plan'} · ${a['totalListings'] ?? 0} listings',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ]),
                trailing: pending
                  ? ElevatedButton(
                      onPressed: () => _approve(a['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success, padding: const EdgeInsets.symmetric(horizontal: 12)),
                      child: const Text('Approve', style: TextStyle(fontSize: 12)))
                  : PopupMenuButton(itemBuilder: (_) => [
                      const PopupMenuItem(value: 'suspend', child: Text('Suspend Agent')),
                      const PopupMenuItem(value: 'view',    child: Text('View Profile')),
                    ]),
              ));
          }),
  );

  Widget _chip(String label, String value) => GestureDetector(
    onTap: () { setState(() => _filter = value); _load(); },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _filter == value ? AppTheme.primary : Colors.white,
        border: Border.all(color: _filter == value ? AppTheme.primary : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(
        color: _filter == value ? Colors.white : const Color(0xFF374151),
        fontSize: 13, fontWeight: FontWeight.w500))));
}

class _PendingListingsTab extends StatefulWidget {
  const _PendingListingsTab();
  @override State<_PendingListingsTab> createState() => _PendingListingsTabState();
}

class _PendingListingsTabState extends State<_PendingListingsTab> {
  List<dynamic> _listings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiClient.instance.get('/admin/properties/pending');
      setState(() { _listings = r.data['content'] ?? []; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _action(String id, bool approve) async {
    try {
      if (approve) {
        await ApiClient.instance.patch('/admin/properties/$id/approve');
      } else {
        await ApiClient.instance.patch('/admin/properties/$id/reject',
          queryParameters: {'reason': 'Does not meet listing guidelines'});
      }
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Pending Review (${_listings.length})')),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : _listings.isEmpty
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.check_circle_outline, size: 56, color: AppTheme.success),
            SizedBox(height: 12),
            Text('All caught up!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('No listings pending review', style: TextStyle(color: Color(0xFF6B7280))),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _listings.length,
            itemBuilder: (_, i) {
              final p = _listings[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(padding: const EdgeInsets.all(14), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text('${p['city']} · ${p['type']} · ${p['purpose']}',
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                    ])),
                    const SizedBox(width: 8),
                    Text('₹${p['price'] ?? ''}', style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                  ]),
                  const SizedBox(height: 6),
                  Text('Agent: ${(p['agent'] as Map?)?['companyName'] ?? '—'}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      icon: const Icon(Icons.close, size: 16, color: AppTheme.danger),
                      label: const Text('Reject', style: TextStyle(color: AppTheme.danger)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.danger)),
                      onPressed: () => _action(p['id'], false))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                      onPressed: () => _action(p['id'], true))),
                  ]),
                ])));
            }));
}
