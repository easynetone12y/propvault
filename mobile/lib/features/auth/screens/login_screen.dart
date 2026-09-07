import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../properties/screens/property_search_screen.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false, _obscure = true;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final dio = ApiClient.instance;
      final resp = await dio.post('/auth/login',
          data: {'email': _email.text.trim(), 'password': _pass.text});
      await ApiClient.saveTokens(resp.data['accessToken'], resp.data['refreshToken']);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PropertySearchScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password'), backgroundColor: AppTheme.danger));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 40),
          RichText(text: const TextSpan(
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, fontFamily: 'Inter', color: Color(0xFF1A1A1A)),
            children: [TextSpan(text: 'Prop', style: TextStyle(color: AppTheme.primary)), TextSpan(text: 'Vault')],
          )),
          const SizedBox(height: 8),
          const Text('India\'s real estate marketplace', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 48),
          const Text('Welcome back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Sign in to continue', style: TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 32),
          Form(key: _form, child: Column(children: [
            TextFormField(
              controller: _email, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)),
              validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pass, obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password', prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure)),
              ),
              validator: (v) => v == null || v.length < 8 ? 'Min 8 characters' : null,
            ),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerRight,
              child: TextButton(onPressed: () {}, child: const Text('Forgot password?'))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                  ? const SizedBox(height: 18, width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Sign In'),
              )),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('New agent? ', style: TextStyle(color: Color(0xFF6B7280))),
              TextButton(onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('Register your agency')),
            ]),
          ])),
        ]),
      )),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  String _role = 'BUYER';
  final _name  = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass  = TextEditingController();
  final _company = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final dio = ApiClient.instance;
      final data = {
        'name': _name.text.trim(), 'email': _email.text.trim(),
        'phone': _phone.text.trim(), 'password': _pass.text,
        'role': _role, if (_role == 'AGENT') 'companyName': _company.text.trim(),
      };
      final resp = await dio.post('/auth/register', data: data);
      await ApiClient.saveTokens(resp.data['accessToken'], resp.data['refreshToken']);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PropertySearchScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e'), backgroundColor: AppTheme.danger));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20),
        child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Account Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            _roleChip('BUYER', 'Buyer / Renter'),
            const SizedBox(width: 10),
            _roleChip('AGENT', 'Real Estate Agent'),
          ]),
          const SizedBox(height: 20),
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (v) => (v?.length ?? 0) < 2 ? 'Required' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => v?.contains('@') == true ? null : 'Invalid email'),
          const SizedBox(height: 12),
          TextFormField(controller: _phone, keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mobile Number', prefixText: '+91 '),
            validator: (v) => (v?.length ?? 0) == 10 ? null : 'Enter 10-digit number'),
          const SizedBox(height: 12),
          if (_role == 'AGENT') ...[
            TextFormField(controller: _company,
              decoration: const InputDecoration(labelText: 'Company / Agency Name'),
              validator: (v) => (v?.length ?? 0) < 2 ? 'Required for agents' : null),
            const SizedBox(height: 12),
          ],
          TextFormField(controller: _pass, obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (v) => (v?.length ?? 0) < 8 ? 'Min 8 characters' : null),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(onPressed: _loading ? null : _register,
              child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : const Text('Create Account'))),
        ]))),
    );
  }

  Widget _roleChip(String value, String label) => GestureDetector(
    onTap: () => setState(() => _role = value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _role == value ? AppTheme.primary : Colors.white,
        border: Border.all(color: _role == value ? AppTheme.primary : const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(
        color: _role == value ? Colors.white : const Color(0xFF374151),
        fontWeight: FontWeight.w600, fontSize: 13)),
    ),
  );
}
