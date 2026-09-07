import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/property_card.dart';
import 'property_detail_screen.dart';

class PropertySearchScreen extends StatefulWidget {
  const PropertySearchScreen({super.key});
  @override State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  final _searchCtrl = TextEditingController();
  List<dynamic> _properties = [];
  bool _loading = false;
  String? _type, _purpose, _bedrooms;
  RangeValues _priceRange = const RangeValues(0, 50000000);
  int _page = 0;
  bool _hasMore = true;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProperties();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 && _hasMore && !_loading)
        _fetchProperties(append: true);
    });
  }

  Future<void> _fetchProperties({bool append = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{
        'page': append ? _page : 0, 'size': 20, 'featuredFirst': true,
        if (_searchCtrl.text.isNotEmpty) 'city': _searchCtrl.text.trim(),
        if (_type != null) 'type': _type,
        if (_purpose != null) 'purpose': _purpose,
        if (_bedrooms != null) 'bedrooms': _bedrooms,
      };
      final r = await ApiClient.instance.get('/properties/search', queryParameters: params);
      final content = r.data['content'] as List;
      setState(() {
        if (append) { _properties.addAll(content); _page++; }
        else        { _properties = content; _page = 1; }
        _hasMore = !r.data['last'];
      });
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PropVault'),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        // Search bar
        Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search city, locality…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18),
                      onPressed: () { _searchCtrl.clear(); _fetchProperties(); })
                  : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => _fetchProperties(),
            )),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _fetchProperties,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              child: const Text('Search')),
          ])),
        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            _filterChip('All Types', _type == null, () { setState(() => _type = null); _fetchProperties(); }),
            _filterChip('Apartment', _type == 'APARTMENT', () { setState(() => _type = 'APARTMENT'); _fetchProperties(); }),
            _filterChip('Villa', _type == 'VILLA', () { setState(() => _type = 'VILLA'); _fetchProperties(); }),
            _filterChip('Plot', _type == 'PLOT', () { setState(() => _type = 'PLOT'); _fetchProperties(); }),
            _filterChip('Commercial', _type == 'COMMERCIAL', () { setState(() => _type = 'COMMERCIAL'); _fetchProperties(); }),
            const SizedBox(width: 8),
            Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
            const SizedBox(width: 8),
            _filterChip('For Sale', _purpose == 'SALE', () { setState(() => _purpose = _purpose == 'SALE' ? null : 'SALE'); _fetchProperties(); }),
            _filterChip('For Rent', _purpose == 'RENT', () { setState(() => _purpose = _purpose == 'RENT' ? null : 'RENT'); _fetchProperties(); }),
            const SizedBox(width: 8),
            _filterChip('1 BHK', _bedrooms == '1', () { setState(() => _bedrooms = _bedrooms == '1' ? null : '1'); _fetchProperties(); }),
            _filterChip('2 BHK', _bedrooms == '2', () { setState(() => _bedrooms = _bedrooms == '2' ? null : '2'); _fetchProperties(); }),
            _filterChip('3 BHK', _bedrooms == '3', () { setState(() => _bedrooms = _bedrooms == '3' ? null : '3'); _fetchProperties(); }),
            _filterChip('4+ BHK', _bedrooms == '4', () { setState(() => _bedrooms = _bedrooms == '4' ? null : '4'); _fetchProperties(); }),
          ]),
        ),
        // Results count
        if (!_loading || _properties.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(alignment: Alignment.centerLeft,
              child: Text('${_properties.length} properties found',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
          ),
        // Property list
        Expanded(child: _loading && _properties.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_off, size: 48, color: Color(0xFFD1D5DB)),
                SizedBox(height: 12),
                Text('No properties found', style: TextStyle(color: Color(0xFF6B7280))),
              ]))
            : RefreshIndicator(
                onRefresh: _fetchProperties,
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: _properties.length + (_hasMore ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == _properties.length)
                      return const Padding(padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PropertyCard(
                        property: _properties[i],
                        onTap: () => Navigator.push(ctx,
                          MaterialPageRoute(builder: (_) =>
                            PropertyDetailScreen(propertyId: _properties[i]['id']))),
                        onFavorite: () {},
                      ),
                    );
                  },
                ),
              )),
      ]),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        selectedIndex: 0,
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          border: Border.all(color: selected ? AppTheme.primary : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: selected ? Colors.white : const Color(0xFF374151))),
      ),
    );
}
