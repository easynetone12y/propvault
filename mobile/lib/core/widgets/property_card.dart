import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  const PropertyCard({super.key, required this.property, this.onTap, this.onFavorite});

  String _fmtPrice(dynamic p) {
    if (p == null) return '—';
    final n = double.tryParse(p.toString()) ?? 0;
    if (n >= 10000000) return '₹${(n / 10000000).toStringAsFixed(2)} Cr';
    if (n >= 100000)   return '₹${(n / 100000).toStringAsFixed(1)} L';
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(n);
  }

  @override
  Widget build(BuildContext context) {
    final media = (property['media'] as List?)?.isNotEmpty == true ? property['media'][0] : null;
    final purpose = property['purpose'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: media != null
                ? CachedNetworkImage(imageUrl: media['mediaUrl'] ?? '',
                    height: 160, width: double.infinity, fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholder(),
                    errorWidget: (_, __, ___) => _placeholder())
                : _placeholder(),
            ),
            // Purpose badge
            Positioned(top: 10, left: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: purpose == 'SALE' ? AppTheme.primary : AppTheme.success,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(purpose, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            )),
            // Featured
            if (property['featured'] == true)
              Positioned(top: 10, right: 10, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(20)),
                child: const Text('★ Featured', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              )),
            // Favorite
            if (onFavorite != null)
              Positioned(bottom: 8, right: 8, child: GestureDetector(
                onTap: onFavorite,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.9), shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border, size: 18, color: AppTheme.danger),
                ),
              )),
          ]),
          // Info
          Padding(padding: const EdgeInsets.all(12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(property['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(_fmtPrice(property['price']),
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              Row(children: [
                _chip(Icons.bed_outlined,      '${property['bedrooms'] ?? '-'} BHK'),
                const SizedBox(width: 8),
                _chip(Icons.square_foot,       '${property['areaSqFt'] ?? '-'} ft²'),
                const SizedBox(width: 8),
                _chip(Icons.location_on_outlined, property['city'] ?? ''),
              ]),
              const SizedBox(height: 6),
              Text('${(property['agent'] as Map?)?['companyName'] ?? ''}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 160, width: double.infinity,
    color: const Color(0xFFEFF6FF),
    child: const Icon(Icons.home_outlined, size: 48, color: AppTheme.primary),
  );

  Widget _chip(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: const Color(0xFF6B7280)),
    const SizedBox(width: 2),
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
  ]);
}
