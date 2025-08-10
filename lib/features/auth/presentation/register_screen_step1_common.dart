import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum Step1Role { user, expert, provider, vendor }

class RegisterStep1CommonScreen extends StatefulWidget {
  const RegisterStep1CommonScreen({super.key});

  @override
  State<RegisterStep1CommonScreen> createState() => _RegisterStep1CommonScreenState();
}

class _RegisterStep1CommonScreenState extends State<RegisterStep1CommonScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  Step1Role _role = Step1Role.user;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = Supabase.instance.client.auth;
      final res = await auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
      );
      final uid = res.user?.id;
      if (uid == null) throw Exception('Sign up failed');

      await Supabase.instance.client.from('profiles').upsert({
        'id': uid,
        'full_name': _name.text.trim(),
        'role': _role.name,
        'city': _city.text.trim(),
        'country': _country.text.trim(),
      });

      if (!mounted) return;
      context.go('/post-register');
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something went wrong')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password (min 8 chars)'),
              obscureText: true,
              validator: (v) => (v == null || v.length < 8) ? 'Min 8 characters' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _country,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Step1Role>(
              value: _role,
              items: Step1Role.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                  .toList(),
              onChanged: (v) => setState(() => _role = v ?? Step1Role.user),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _create,
              child: _loading ? const CircularProgressIndicator() : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
