import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AddPropertyScreen extends StatefulWidget {
  final Map<String, dynamic>? existing; // null = create, non-null = edit
  const AddPropertyScreen({super.key, this.existing});
  @override State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _form  = GlobalKey<FormState>();
  int  _step   = 0; // 0=Basic 1=Location 2=Details 3=Media
  bool _loading = false;

  // Controllers
  final _title       = TextEditingController();
  final _description = TextEditingController();
  final _price       = TextEditingController();
  final _address     = TextEditingController();
  final _locality    = TextEditingController();
  final _city        = TextEditingController();
  final _pincode     = TextEditingController();
  final _areaSqFt    = TextEditingController();
  final _virtualTour = TextEditingController();

  String _type      = 'APARTMENT';
  String _purpose   = 'SALE';
  String _furnishing = 'Unfurnished';
  int    _bedrooms  = 2;
  int    _bathrooms = 2;
  List<String>  _selectedAmenities = [];
  List<XFile>   _images = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) _prefill();
  }

  void _prefill() {
    final p = widget.existing!;
    _title.text       = p['title'] ?? '';
    _description.text = p['description'] ?? '';
    _price.text       = p['price']?.toString() ?? '';
    _address.text     = p['address'] ?? '';
    _locality.text    = p['locality'] ?? '';
    _city.text        = p['city'] ?? '';
    _pincode.text     = p['pincode'] ?? '';
    _areaSqFt.text    = p['areaSqFt']?.toString() ?? '';
    _virtualTour.text = p['virtualTourUrl'] ?? '';
    _type      = p['type'] ?? 'APARTMENT';
    _purpose   = p['purpose'] ?? 'SALE';
    _bedrooms  = p['bedrooms'] ?? 2;
    _bathrooms = p['bathrooms'] ?? 2;
    _selectedAmenities = List<String>.from(p['amenities'] ?? []);
  }

  Future<void> _pickImages() async {
    final imgs = await _picker.pickMultiImage(imageQuality: 75);
    setState(() => _images.addAll(imgs));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) { setState(() => _step = 0); return; }
    setState(() => _loading = true);
    try {
      final isEdit = widget.existing != null;
      final endpoint = isEdit ? '/properties/${widget.existing!['id']}' : '/properties';

      // Build multipart if images are present
      if (_images.isNotEmpty) {
        final formData = {
          'title':        _title.text.trim(),
          'description':  _description.text.trim(),
          'type':         _type,
          'purpose':      _purpose,
          'price':        _price.text.trim(),
          'address':      _address.text.trim(),
          'locality':     _locality.text.trim(),
          'city':         _city.text.trim(),
          'pincode':      _pincode.text.trim(),
          'areaSqFt':     _areaSqFt.text.trim(),
          'bedrooms':     _bedrooms.toString(),
          'bathrooms':    _bathrooms.toString(),
          'furnishingStatus': _furnishing.toUpperCase().replaceAll('-', '_').replaceAll(' ', '_'),
          'virtualTourUrl': _virtualTour.text.trim(),
          'amenities':    _selectedAmenities.join(','),
        };
        // Upload via multipart
        await ApiClient.instance.request(
          endpoint,
          options: isEdit ? null : null, // POST or PUT
          data: formData,
        );
      } else {
        final data = {
          'title': _title.text.trim(), 'description': _description.text.trim(),
          'type': _type, 'purpose': _purpose, 'price': double.parse(_price.text),
          'address': _address.text.trim(), 'locality': _locality.text.trim(),
          'city': _city.text.trim(), 'pincode': _pincode.text.trim(),
          'areaSqFt': double.tryParse(_areaSqFt.text) ?? 0,
          'bedrooms': _bedrooms, 'bathrooms': _bathrooms,
          'furnishingStatus': _furnishing.toUpperCase().replaceAll(' ', '_'),
          'virtualTourUrl': _virtualTour.text.trim(),
          'amenities': _selectedAmenities,
        };
        if (isEdit) {
          await ApiClient.instance.put(endpoint, data: data);
        } else {
          await ApiClient.instance.post(endpoint, data: data);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit ? 'Property updated! Pending review.' : 'Property submitted for review!'),
          backgroundColor: AppTheme.success));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.danger));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? 'Edit Property' : 'Add Property'),
        actions: [
          if (_step > 0) TextButton(onPressed: () => setState(() => _step--), child: const Text('Back')),
        ],
      ),
      body: Column(children: [
        // Step indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: List.generate(4, (i) {
            final labels = ['Basic Info', 'Location', 'Details', 'Media'];
            final active = i == _step;
            final done   = i < _step;
            return Expanded(child: Row(children: [
              Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? AppTheme.success : active ? AppTheme.primary : const Color(0xFFE5E7EB),
                  ),
                  child: Center(child: done
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text('${i+1}', style: TextStyle(
                        color: active ? Colors.white : const Color(0xFF9CA3AF),
                        fontSize: 12, fontWeight: FontWeight.w600))),
                ),
                const SizedBox(height: 4),
                Text(labels[i], style: TextStyle(
                  fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active ? AppTheme.primary : const Color(0xFF9CA3AF))),
              ]),
              if (i < 3) Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 16),
                color: done ? AppTheme.success : const Color(0xFFE5E7EB))),
            ]));
          })),
        ),

        Expanded(child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: [_basicInfoStep(), _locationStep(), _detailsStep(), _mediaStep()][_step],
          ),
        )),
      ]),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        color: Colors.white,
        child: SizedBox(height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : () {
              if (_step < 3) { setState(() => _step++); }
              else           { _submit(); }
            },
            child: _loading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(_step < 3 ? 'Continue →' : 'Submit for Review'),
          )),
      ),
    );
  }

  Widget _basicInfoStep() => Column(children: [
    _label('Property Title *'),
    TextFormField(controller: _title, decoration: const InputDecoration(hintText: 'e.g. Spacious 3 BHK in South Delhi'),
      validator: (v) => (v?.length ?? 0) < 10 ? 'Min 10 characters' : null),
    const SizedBox(height: 16),
    _label('Description *'),
    TextFormField(controller: _description, maxLines: 4,
      decoration: const InputDecoration(hintText: 'Describe key features, surroundings…'),
      validator: (v) => (v?.length ?? 0) < 20 ? 'Min 20 characters' : null),
    const SizedBox(height: 16),
    _label('Property Type'),
    _segmented(AppConstants.propertyTypes, _type, (v) => setState(() => _type = v.toUpperCase().replaceAll(' ', '_'))),
    const SizedBox(height: 16),
    _label('Purpose'),
    Row(children: [
      Expanded(child: _toggleBtn('For Sale', _purpose == 'SALE', () => setState(() => _purpose = 'SALE'))),
      const SizedBox(width: 10),
      Expanded(child: _toggleBtn('For Rent', _purpose == 'RENT', () => setState(() => _purpose = 'RENT'))),
    ]),
    const SizedBox(height: 16),
    _label('Price (₹) *'),
    TextFormField(controller: _price, keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixText: '₹ ',
        hintText: _purpose == 'SALE' ? 'e.g. 8500000' : 'e.g. 35000 /month'),
      validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0 ? null : 'Enter valid price'),
    const SizedBox(height: 24),
  ]);

  Widget _locationStep() => Column(children: [
    _label('Full Address'),
    TextFormField(controller: _address, decoration: const InputDecoration(hintText: 'House no, Street, Colony…'),
      validator: (v) => (v?.length ?? 0) < 5 ? 'Required' : null),
    const SizedBox(height: 12),
    _label('Locality / Area *'),
    TextFormField(controller: _locality, decoration: const InputDecoration(hintText: 'e.g. Vasant Kunj, Bandra West'),
      validator: (v) => (v?.length ?? 0) < 2 ? 'Required' : null),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('City *'),
        TextFormField(controller: _city, decoration: const InputDecoration(hintText: 'Delhi'),
          validator: (v) => (v?.length ?? 0) < 2 ? 'Required' : null),
      ])),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('PIN Code'),
        TextFormField(controller: _pincode, keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '110001')),
      ])),
    ]),
    const SizedBox(height: 16),
    Container(
      height: 160, decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFD9F5))),
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.map_outlined, size: 36, color: AppTheme.primary),
        SizedBox(height: 8),
        Text('Tap to pin location on map', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        Text('Google Maps integration', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      ]),
    ),
    const SizedBox(height: 24),
  ]);

  Widget _detailsStep() => Column(children: [
    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Bedrooms'),
        _stepper(_bedrooms, (v) => setState(() => _bedrooms = v)),
      ])),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Bathrooms'),
        _stepper(_bathrooms, (v) => setState(() => _bathrooms = v)),
      ])),
    ]),
    const SizedBox(height: 16),
    _label('Total Area (sq ft)'),
    TextFormField(controller: _areaSqFt, keyboardType: TextInputType.number,
      decoration: const InputDecoration(hintText: 'e.g. 1450', suffixText: 'sq ft')),
    const SizedBox(height: 16),
    _label('Furnishing'),
    _segmented(AppConstants.furnishing, _furnishing, (v) => setState(() => _furnishing = v)),
    const SizedBox(height: 16),
    _label('Virtual Tour Link (optional)'),
    TextFormField(controller: _virtualTour,
      decoration: const InputDecoration(hintText: 'https://matterport.com/…', prefixIcon: Icon(Icons.view_in_ar_outlined))),
    const SizedBox(height: 16),
    _label('Amenities'),
    Wrap(spacing: 8, runSpacing: 8,
      children: AppConstants.amenities.map((a) {
        final sel = _selectedAmenities.contains(a);
        return FilterChip(
          label: Text(a), selected: sel,
          onSelected: (v) => setState(() => v ? _selectedAmenities.add(a) : _selectedAmenities.remove(a)),
          selectedColor: const Color(0xFFEFF6FF),
          checkmarkColor: AppTheme.primary,
          labelStyle: TextStyle(fontSize: 12, color: sel ? AppTheme.primary : const Color(0xFF374151)),
        );
      }).toList()),
    const SizedBox(height: 24),
  ]);

  Widget _mediaStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Upload Images', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
    const SizedBox(height: 4),
    const Text('First image will be the cover photo. Max 20 images, 10MB each.',
      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
    const SizedBox(height: 12),
    // Image grid
    GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemCount: _images.length + 1,
      itemBuilder: (ctx, i) {
        if (i == _images.length) {
          return GestureDetector(
            onTap: _pickImages,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF), borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFD9F5), style: BorderStyle.solid)),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppTheme.primary),
                SizedBox(height: 4),
                Text('Add Photos', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w500)),
              ]),
            ),
          );
        }
        return Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(File(_images[i].path), fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
          if (i == 0) Positioned(top: 4, left: 4, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
            child: const Text('Cover', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)))),
          Positioned(top: 4, right: 4, child: GestureDetector(
            onTap: () => setState(() => _images.removeAt(i)),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white)))),
        ]);
      },
    ),
    const SizedBox(height: 20),
    const Text('Tips for great listings:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    const SizedBox(height: 8),
    ...[
      '📸 Use well-lit, high-resolution photos',
      '🏠 Include exterior, all rooms, and kitchen',
      '🪟 Capture views from windows if applicable',
      '📐 Add floor plan image for better leads',
    ].map((t) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))))),
    const SizedBox(height: 24),
  ]);

  // ── Helpers ──────────────────────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))));

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : Colors.white,
        border: Border.all(color: active ? AppTheme.primary : const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(10)),
      child: Center(child: Text(label, style: TextStyle(
        color: active ? Colors.white : const Color(0xFF374151), fontWeight: FontWeight.w600, fontSize: 14)))));

  Widget _segmented(List<String> options, String current, Function(String) onSelect) =>
    Wrap(spacing: 8, runSpacing: 8,
      children: options.map((o) {
        final key = o.toUpperCase().replaceAll(' ', '_');
        final active = current == key || current == o;
        return GestureDetector(
          onTap: () => onSelect(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : Colors.white,
              border: Border.all(color: active ? AppTheme.primary : const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(20)),
            child: Text(o, style: TextStyle(
              color: active ? Colors.white : const Color(0xFF374151),
              fontWeight: active ? FontWeight.w600 : FontWeight.normal, fontSize: 13))));
      }).toList());

  Widget _stepper(int value, Function(int) onChange) => Container(
    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D5DB)), borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      IconButton(icon: const Icon(Icons.remove, size: 18),
        onPressed: value > 0 ? () => onChange(value - 1) : null),
      Expanded(child: Text('$value', textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
      IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => onChange(value + 1)),
    ]));
}
