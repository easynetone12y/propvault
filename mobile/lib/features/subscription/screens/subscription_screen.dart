import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<dynamic> _plans = [];
  Map<String, dynamic>? _currentSub;
  List<dynamic> _invoices = [];
  bool _loading = true;
  bool _yearly  = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,   _onPayError);
    _loadData();
  }

  @override
  void dispose() { _razorpay.clear(); super.dispose(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiClient.instance.get('/subscription-plans'),
        ApiClient.instance.get('/payments/invoices'),
      ]);
      // Current subscription from agent profile
      try {
        final sub = await ApiClient.instance.get('/agents/me/subscription');
        setState(() => _currentSub = sub.data);
      } catch (_) {}
      setState(() {
        _plans    = results[0].data ?? [];
        _invoices = results[1].data['content'] ?? [];
        _loading  = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _subscribe(Map<String, dynamic> plan) async {
    try {
      final r = await ApiClient.instance.post('/payments/subscribe', data: {
        'planId': plan['id'], 'yearly': _yearly,
      });
      final opts = {
        'key':           r.data['keyId'],
        'subscription_id': r.data['subscriptionId'],
        'name':          'PropVault',
        'description':   '${plan['displayName']} Plan – ${_yearly ? "Annual" : "Monthly"}',
        'prefill':       {'contact': '', 'email': ''},
        'theme':         {'color': '#185FA5'},
      };
      _razorpay.open(opts);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not initiate payment: $e'), backgroundColor: AppTheme.danger));
    }
  }

  void _onPaySuccess(PaymentSuccessResponse resp) async {
    try {
      await ApiClient.instance.post('/payments/verify', data: {
        'razorpay_payment_id':    resp.paymentId,
        'razorpay_subscription_id': resp.data?['subscription_id'] ?? '',
        'razorpay_signature':     resp.signature,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Subscription activated!'), backgroundColor: AppTheme.success));
        _loadData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e'), backgroundColor: AppTheme.danger));
    }
  }

  void _onPayError(PaymentFailureResponse resp) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${resp.message}'), backgroundColor: AppTheme.danger));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription & Plans')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Current plan card
              if (_currentSub != null) _CurrentPlanCard(sub: _currentSub!),

              const SizedBox(height: 24),

              // Billing toggle
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Monthly', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Switch(value: _yearly, onChanged: (v) => setState(() => _yearly = v), activeColor: AppTheme.primary),
                const SizedBox(width: 10),
                const Text('Yearly', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                  child: const Text('Save 17%', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 16),

              // Plan cards
              ..._plans.map((plan) => _PlanCard(
                plan: plan, yearly: _yearly,
                isCurrent: _currentSub?['planName'] == plan['name'],
                onSubscribe: () => _subscribe(plan),
              )),

              // Invoices
              if (_invoices.isNotEmpty) ...[
                const SizedBox(height: 28),
                const Text('Billing History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ..._invoices.map((inv) => _InvoiceRow(invoice: inv)),
              ],
            ]),
          ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final Map<String, dynamic> sub;
  const _CurrentPlanCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    final used    = sub['listingsUsed'] as int? ?? 0;
    final max     = sub['maxListings']  as int? ?? 1;
    final pct     = max == -1 ? 0.3 : (used / max).clamp(0.0, 1.0);
    final status  = sub['status'] as String? ?? '';
    final statusColors = {'ACTIVE': AppTheme.success, 'TRIAL': AppTheme.warning, 'PAST_DUE': AppTheme.danger};
    final c = statusColors[status] ?? const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withOpacity(.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('${sub['planDisplayName'] ?? 'Plan'} Plan',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: c.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _infoItem('Listings', max == -1 ? '$used / ∞' : '$used / $max'),
          const SizedBox(width: 24),
          _infoItem('Renews', sub['currentPeriodEnd'] ?? '—'),
          const SizedBox(width: 24),
          _infoItem('Auto-renew', sub['autoRenew'] == true ? 'On' : 'Off'),
        ]),
        if (max != -1) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct, minHeight: 6, backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(pct > 0.8 ? AppTheme.warning : AppTheme.primary))),
        ],
        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton(onPressed: () {}, child: const Text('Download Invoice')),
          const SizedBox(width: 10),
          TextButton(onPressed: () {}, style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Cancel Plan')),
        ]),
      ]));
  }

  Widget _infoItem(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
    Text(value,  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  ]);
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool yearly, isCurrent;
  final VoidCallback onSubscribe;
  const _PlanCard({required this.plan, required this.yearly, required this.isCurrent, required this.onSubscribe});

  static const _features = {
    'BASIC':   ['20 property listings', 'Lead management', 'Agent profile page', 'WhatsApp integration'],
    'PRO':     ['100 property listings', '5 featured slots/month', 'Video uploads', 'Analytics dashboard', 'WhatsApp integration'],
    'PREMIUM': ['Unlimited listings', 'Unlimited featured', 'Priority lead routing', 'AI description generator', 'Verified agent badge', 'Full analytics'],
  };

  @override
  Widget build(BuildContext context) {
    final name     = plan['name'] as String? ?? '';
    final monthly  = (plan['priceMonthly'] as num?)?.toInt() ?? 0;
    final yearly   = (plan['priceYearly']  as num?)?.toInt() ?? 0;
    final price    = this.yearly ? yearly : monthly;
    final isPro    = name == 'PRO';
    final features = _features[name] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isPro ? AppTheme.primary : const Color(0xFFE5E7EB), width: isPro ? 2 : 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (isPro) Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: const Text('⭐ Most Popular', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
        Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(plan['displayName'] ?? name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('₹${_fmtNum(price)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            Text(this.yearly ? '/year' : '/month', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ]),
          const SizedBox(height: 4),
          Text('+ 18% GST', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
          const SizedBox(height: 14),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.success),
              const SizedBox(width: 8),
              Text(f, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
            ]))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 44,
            child: isCurrent
              ? OutlinedButton(onPressed: null, child: const Text('Current Plan'))
              : ElevatedButton(onPressed: onSubscribe,
                  style: isPro ? null : ElevatedButton.styleFrom(backgroundColor: const Color(0xFF374151)),
                  child: const Text('Subscribe Now'))),
        ])),
      ]));
  }

  String _fmtNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 2)}K';
    return n.toString();
  }
}

class _InvoiceRow extends StatelessWidget {
  final Map<String, dynamic> invoice;
  const _InvoiceRow({required this.invoice});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Row(children: [
      const Icon(Icons.receipt_outlined, size: 20, color: AppTheme.primary),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(invoice['invoiceNumber'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(invoice['invoiceDate'] ?? '', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('₹${invoice['totalAmount'] ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
          child: const Text('Paid', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(width: 8),
      IconButton(icon: const Icon(Icons.download_outlined, size: 18), onPressed: () {}),
    ]));
}
