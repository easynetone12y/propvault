import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

class ContactAgentSheet extends StatefulWidget {
  final Map<String, dynamic> property;
  const ContactAgentSheet({super.key, required this.property});
  @override State<ContactAgentSheet> createState() => _ContactAgentSheetState();
}

class _ContactAgentSheetState extends State<ContactAgentSheet> {
  final _form = GlobalKey<FormState>();
  final _name    = TextEditingController();
  final _phone   = TextEditingController();
  final _email   = TextEditingController();
  final _message = TextEditingController();
  bool _loading  = false;
  bool _done     = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiClient.instance.post(
        '/leads/property/${widget.property['id']}',
        data: {
          'customerName':  _name.text.trim(),
          'customerPhone': _phone.text.trim(),
          'customerEmail': _email.text.trim(),
          'message':       _message.text.trim(),
          'source':        'FORM',
        },
      );
      setState(() { _done = true; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send. Try again.'), backgroundColor: AppTheme.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _done ? _successView() : _formView(),
      ),
    );
  }

  Widget _successView() => Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.check_circle_outline, size: 60, color: AppTheme.success),
    const SizedBox(height: 12),
    const Text('Request Sent!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    const Text('The agent will contact you within 24 hours.',
      textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B7280))),
    const SizedBox(height: 20),
    SizedBox(width: double.infinity,
      child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))),
    const SizedBox(height: 8),
  ]);

  Widget _formView() => Form(
    key: _form,
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Contact Agent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(widget.property['title'] ?? '',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ]),
      const SizedBox(height: 16),
      TextFormField(
        controller: _name,
        decoration: const InputDecoration(labelText: 'Your Name', prefixIcon: Icon(Icons.person_outline)),
        validator: (v) => (v?.length ?? 0) < 2 ? 'Required' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _phone, keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Mobile Number', prefixText: '+91 ', prefixIcon: Icon(Icons.phone_outlined)),
        validator: (v) => (v?.length ?? 0) == 10 ? null : 'Enter 10-digit number',
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _email, keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email (optional)', prefixIcon: Icon(Icons.email_outlined)),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _message, maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Message',
          hintText: 'I am interested in this property…',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 48,
        child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Send Enquiry'),
        )),
      const SizedBox(height: 8),
    ]),
  );
}
