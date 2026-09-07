import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../leads/screens/contact_agent_sheet.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});
  @override State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  Map<String, dynamic>? _property;
  bool _loading = true;
  int _imgIndex = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await ApiClient.instance.get('/properties/${widget.propertyId}');
      setState(() { _property = r.data; _loading = false; });
    } catch (e) { setState(() => _loading = false); }
  }

  String _fmtPrice(dynamic p) {
    final n = double.tryParse(p?.toString() ?? '0') ?? 0;
    if (n >= 10000000) return '₹${(n/10000000).toStringAsFixed(2)} Cr';
    if (n >= 100000)   return '₹${(n/100000).toStringAsFixed(1)} L';
    return NumberFormat.currency(locale:'en_IN', symbol:'₹', decimalDigits:0).format(n);
  }

  void _callAgent() async {
    final phone = (_property?['agent'] as Map?)?['phone'];
    if (phone != null) launchUrl(Uri.parse('tel:+91$phone'));
  }

  void _whatsappAgent() async {
    final phone = (_property?['agent'] as Map?)?['phone'];
    final title = _property?['title'] ?? '';
    if (phone != null) launchUrl(Uri.parse(
      'https://wa.me/91$phone?text=${Uri.encodeComponent("Hi! I'm interested in: $title")}'));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_property == null) return const Scaffold(body: Center(child: Text('Property not found')));

    final media = (_property!['media'] as List?) ?? [];
    final agent = (_property!['agent'] as Map?) ?? {};
    final amenities = (_property!['amenities'] as List?) ?? [];

    return Scaffold(
      body: CustomScrollView(slivers: [
        // Hero image carousel
        SliverAppBar(
          expandedHeight: 280, pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: media.isNotEmpty
              ? CarouselSlider(
                  options: CarouselOptions(
                    height: 280, viewportFraction: 1.0, enableInfiniteScroll: false,
                    onPageChanged: (i, _) => setState(() => _imgIndex = i)),
                  items: media.map((m) => CachedNetworkImage(
                    imageUrl: m['mediaUrl'] ?? '',
                    fit: BoxFit.cover, width: double.infinity,
                    placeholder: (_, __) => Container(color: const Color(0xFFEFF6FF)),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFEFF6FF),
                      child: const Icon(Icons.home, size: 60, color: AppTheme.primary)),
                  )).toList(),
                )
              : Container(color: const Color(0xFFEFF6FF),
                  child: const Icon(Icons.home_outlined, size: 80, color: AppTheme.primary)),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
          ],
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Image dots
            if (media.length > 1) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(media.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _imgIndex == i ? 18 : 6, height: 6,
                decoration: BoxDecoration(
                  color: _imgIndex == i ? AppTheme.primary : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(3)),
              )),
            ),
            if (media.length > 1) const SizedBox(height: 16),

            // Badges
            Row(children: [
              _badge(_property!['purpose'] == 'SALE' ? 'For Sale' : 'For Rent',
                _property!['purpose'] == 'SALE' ? AppTheme.primary : AppTheme.success),
              const SizedBox(width: 8),
              _badge(_property!['type']?.toString().replaceAll('_', ' ') ?? '', const Color(0xFF6B7280)),
              if (_property!['featured'] == true) ...[
                const SizedBox(width: 8),
                _badge('★ Featured', Colors.amber.shade700),
              ],
            ]),
            const SizedBox(height: 10),

            // Title & Price
            Text(_property!['title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 2),
              Text('${_property!['locality'] ?? ''}, ${_property!['city'] ?? ''}',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            ]),
            const SizedBox(height: 12),
            Text(_fmtPrice(_property!['price']),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            if (_property!['purpose'] == 'RENT')
              const Text('/month', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Key details grid
            const Text('Property Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2, mainAxisSpacing: 10, crossAxisSpacing: 10,
              children: [
                if (_property!['bedrooms'] != null) _detailTile(Icons.bed_outlined, 'Bedrooms', '${_property!['bedrooms']} BHK'),
                if (_property!['bathrooms'] != null) _detailTile(Icons.bathtub_outlined, 'Bathrooms', '${_property!['bathrooms']}'),
                if (_property!['areaSqFt'] != null) _detailTile(Icons.square_foot, 'Area', '${_property!['areaSqFt']} ft²'),
                if (_property!['floor'] != null) _detailTile(Icons.layers_outlined, 'Floor', '${_property!['floor']} / ${_property!['totalFloors'] ?? '-'}'),
                if (_property!['buildYear'] != null) _detailTile(Icons.calendar_today_outlined, 'Build Year', '${_property!['buildYear']}'),
                if (_property!['furnishingStatus'] != null) _detailTile(Icons.chair_outlined, 'Furnishing', '${_property!['furnishingStatus']}'),
              ],
            ),

            // Description
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(_property!['description'] ?? 'No description provided.',
              style: const TextStyle(color: Color(0xFF374151), height: 1.6, fontSize: 14)),

            // Amenities
            if (amenities.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Amenities', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: amenities.map((a) =>
                Chip(label: Text(a.toString()),
                  avatar: const Icon(Icons.check_circle_outline, size: 14, color: AppTheme.primary))
              ).toList()),
            ],

            // Virtual Tour
            if (_property!['virtualTourUrl'] != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.view_in_ar_outlined),
                label: const Text('View Virtual Tour'),
                onPressed: () => launchUrl(Uri.parse(_property!['virtualTourUrl'])),
              ),
            ],

            // Agent Card
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Listed By', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Card(child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                CircleAvatar(
                  radius: 24, backgroundColor: const Color(0xFFEFF6FF),
                  backgroundImage: agent['logoUrl'] != null ? NetworkImage(agent['logoUrl']) : null,
                  child: agent['logoUrl'] == null
                    ? Text((agent['companyName'] as String? ?? 'A')[0],
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 18))
                    : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(agent['companyName'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (agent['verified'] == true) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 16, color: AppTheme.primary),
                    ],
                  ]),
                  Text(agent['name'] ?? '',
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                  Text('${agent['city'] ?? ''}',
                    style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                ])),
                Text('${agent['totalListings'] ?? ''} listings',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ]),
            )),

            const SizedBox(height: 100), // space for bottom bar
          ]),
        )),
      ]),

      // Bottom action bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Row(children: [
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const Text('Call'),
            onPressed: _callAgent,
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(
            icon: const Icon(Icons.chat_outlined, size: 18),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: _whatsappAgent,
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: const Text('Visit'),
            onPressed: () => showModalBottomSheet(
              context: context, isScrollControlled: true,
              builder: (_) => ContactAgentSheet(property: _property!)),
          )),
        ]),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(.12),
      borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(.3))),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  Widget _detailTile(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: AppTheme.primary),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );
}
