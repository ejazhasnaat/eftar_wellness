// lib/features/onboarding/presentation/step2_provider_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/data/profile_repository.dart';
import '../data/provider_repository.dart';

class Step2ProviderScreen extends StatefulWidget {
  const Step2ProviderScreen({super.key});

  @override
  State<Step2ProviderScreen> createState() => _Step2ProviderScreenState();
}

class _Step2ProviderScreenState extends State<Step2ProviderScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _range = TextEditingController(text: '5');
  final _city = TextEditingController();
  final _country = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  Future<void> _prefillFromProfile() async {
    final client = Supabase.instance.client;
    final p = await ProfileRepository(client).getProfile();
    if (p != null) {
      _city.text = (p['city'] as String?) ?? '';
      _country.text = (p['country'] as String?) ?? '';
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final client = Supabase.instance.client;
      final repo = ProviderRepository(client);
      await repo.upsertProviderForCurrentUser(
        name: _name.text.trim(),
        deliveryRangeKm: int.tryParse(_range.text.trim()) ?? 5,
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        country: _country.text.trim().isEmpty ? null : _country.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Submitted. Your provider account is pending approval.'),
      ));
      context.go('/home/provider');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _range.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 12);
    return Scaffold(
      appBar: AppBar(title: const Text('Healthy Meals Provider — Step 2')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Provide your details (approval required)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            spacing,
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Business / Provider Name'),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'Enter a valid name' : null,
            ),
            spacing,
            TextFormField(
              controller: _range,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Delivery range (km)'),
              validator: (v) =>
                  (v == null || int.tryParse(v) == null) ? 'Enter a number' : null,
            ),
            spacing,
            TextFormField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            spacing,
            TextFormField(
              controller: _country,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _save,
              child:
                  _submitting ? const CircularProgressIndicator() : const Text('Submit for approval'),
            ),
          ],
        ),
      ),
    );
  }
}

