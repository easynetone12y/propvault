import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});
  @override State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _statusTabs = ['ALL', 'NEW', 'FOLLOW_UP', 'VISIT_SCHEDULED', 'CLOSED_WON', 'CLOSED_LOST'];
  List<dynamic> _leads = [];
  bool _loading = true;
  String _activeStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _statusTabs.length, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        setState(() => _activeStatus = _statusTabs[_tabs.index]);
        _fetch();
      }
    });
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{'page': 0, 'size': 50};
      if (_activeStatus != 'ALL') params['status'] = _activeStatus;
      final r = await ApiClient.instance.get('/leads/my', queryParameters: params);
      setState(() { _leads = r.data['content'] ?? []; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _updateStatus(String leadId, String newStatus, {String? notes}) async {
    try {
      await ApiClient.instance.patch('/leads/$leadId/status',
        data: {'status': newStatus, if (notes != null) 'notes': notes});
      _fetch();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update failed'), backgroundColor: AppTheme.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _statusTabs.map((s) => Tab(text: s.replaceAll('_', ' '))).toList(),
        ),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _leads.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.people_outline, size: 56, color: Color(0xFFD1D5DB)),
              SizedBox(height: 12),
              Text('No leads yet', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
              SizedBox(height: 4),
              Text('Leads from property enquiries appear here', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
            ]))
          : RefreshIndicator(
              onRefresh: _fetch,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _leads.length,
                itemBuilder: (ctx, i) => _LeadCard(
                  lead: _leads[i],
                  onStatusUpdate: (status) => _updateStatus(_leads[i]['id'], status),
                ),
              ),
            ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final Map<String, dynamic> lead;
  final Function(String) onStatusUpdate;
  const _LeadCard({required this.lead, required this.onStatusUpdate});

  Color _statusColor(String s) => switch (s) {
    'NEW'            => AppTheme.primary,
    'FOLLOW_UP'      => AppTheme.warning,
    'VISIT_SCHEDULED'=> const Color(0xFF7C3AED),
    'CLOSED_WON'     => AppTheme.success,
    'CLOSED_LOST'    => AppTheme.danger,
    _                => const Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final status = lead['status'] as String? ?? 'NEW';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 20, backgroundColor: const Color(0xFFEFF6FF),
              child: Text((lead['customerName'] as String? ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lead['customerName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(lead['customerPhone'] ?? '', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor(status).withOpacity(.3)),
              ),
              child: Text(status.replaceAll('_', ' '),
                style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
          if (lead['propertyTitle'] != null) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.home_outlined, size: 14, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Expanded(child: Text(lead['propertyTitle'] ?? '',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ],
          if (lead['message'] != null && (lead['message'] as String).isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('"${lead['message']}"',
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontStyle: FontStyle.italic),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _sourceChip(lead['source'] ?? 'FORM')),
            const Spacer(),
            // Quick action buttons
            _actionBtn(context, Icons.phone_outlined, 'Call', AppTheme.primary, () {
              // launch tel
            }),
            const SizedBox(width: 6),
            _actionBtn(context, Icons.chat_outlined, 'WA', AppTheme.accent, () {
              // launch whatsapp
            }),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: onStatusUpdate,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'CONTACTED',        child: Text('Mark Contacted')),
                const PopupMenuItem(value: 'FOLLOW_UP',        child: Text('Follow Up')),
                const PopupMenuItem(value: 'VISIT_SCHEDULED',  child: Text('Schedule Visit')),
                const PopupMenuItem(value: 'CLOSED_WON',       child: Text('✅ Closed – Won')),
                const PopupMenuItem(value: 'CLOSED_LOST',      child: Text('❌ Closed – Lost')),
              ],
            ),
          ]),
        ],
      )),
    );
  }

  Widget _sourceChip(String source) {
    final colors = {'FORM': AppTheme.primary, 'WHATSAPP': AppTheme.accent, 'CALL': AppTheme.success};
    final c = colors[source] ?? const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
      child: Text(source, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionBtn(BuildContext ctx, IconData icon, String label, Color color, VoidCallback onTap) =>
    InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ));
}
