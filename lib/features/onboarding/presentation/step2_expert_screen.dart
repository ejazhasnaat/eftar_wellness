// lib/features/onboarding/presentation/step2_expert_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/role.dart';
import '../data/expert_repository.dart';

class Step2ExpertScreen extends StatefulWidget {
  const Step2ExpertScreen({super.key});

  @override
  State<Step2ExpertScreen> createState() => _Step2ExpertScreenState();
}

class _Step2ExpertScreenState extends State<Step2ExpertScreen> {
  final _form = GlobalKey<FormState>();
  final _bio = TextEditingController();
  final _experience = TextEditingController(text: '0');
  final _rate = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();

  String _expertType = 'dietitian'; // dietitian | fitness_expert
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
      final role = roleFromString(p['role'] as String?);
      if (role == UserRole.fitnessExpert) {
        _expertType = 'fitness_expert';
      } else if (role == UserRole.dietitian) {
        _expertType = 'dietitian';
      }
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final client = Supabase.instance.client;
      final repo = ExpertRepository(client);

      // Simple weekly availability example
      final availability = {
        "timezone": DateTime.now().timeZoneName,
        "weekly": [
          {"day": "Mon", "slots": ["09:00-12:00", "14:00-17:00"]},
          {"day": "Tue", "slots": ["09:00-12:00"]},
          {"day": "Wed", "slots": ["09:00-12:00", "14:00-17:00"]},
          {"day": "Thu", "slots": []},
          {"day": "Fri", "slots": ["10:00-13:00"]},
          {"day": "Sat", "slots": []},
          {"day": "Sun", "slots": []},
        ]
      };

      await repo.upsertExpertForCurrentUser(
        expertType: _expertType,
        bio: _bio.text.trim(),
        experienceYears: int.tryParse(_experience.text.trim()) ?? 0,
        ratePerAppointment: _rate.text.trim().isEmpty
            ? null
            : num.tryParse(_rate.text.trim()),
        availability: availability,
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        country: _country.text.trim().isEmpty ? null : _country.text.trim(),
      );

      if (!mounted) return;
      // Show info that approval is pending
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Submitted. Your account is pending approval.'),
      ));
      context.go('/home/expert');
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
    _bio.dispose();
    _experience.dispose();
    _rate.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 12);
    return Scaffold(
      appBar: AppBar(title: const Text('Expert — Step 2')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Tell us about your expertise (approval required)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            spacing,
            DropdownButtonFormField<String>(
              value: _expertType,
              items: const [
                DropdownMenuItem(value: 'dietitian', child: Text('Dietitian/Nutrition Expert')),
                DropdownMenuItem(value: 'fitness_expert', child: Text('Fitness Expert')),
              ],
              onChanged: (v) => setState(() => _expertType = v ?? 'dietitian'),
              decoration: const InputDecoration(labelText: 'Expert Type'),
            ),
            spacing,
            TextFormField(
              controller: _bio,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Bio'),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Please add a short bio (min 10 chars)'
                  : null,
            ),
            spacing,
            TextFormField(
              controller: _experience,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Experience (years)'),
              validator: (v) =>
                  (v == null || int.tryParse(v) == null) ? 'Enter a number' : null,
            ),
            spacing,
            TextFormField(
              controller: _rate,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rate per appointment (optional)'),
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

