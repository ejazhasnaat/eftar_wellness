// lib/features/onboarding/presentation/expert_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../onboarding/domain/expert_kind.dart';
import '../../onboarding/domain/expert_onboarding_repository.dart';
import '../../onboarding/data/expert_onboarding_repository_prefs.dart';
import '../../auth/application/auth_controller.dart';

final expertOnboardingRepoProvider = Provider<ExpertOnboardingRepository>((ref) {
  return ExpertOnboardingRepositoryPrefs(); // swap with Supabase later
});

class ExpertDetailsScreen extends ConsumerStatefulWidget {
  const ExpertDetailsScreen({super.key, this.suggestedKind});
  final ExpertKind? suggestedKind;

  @override
  ConsumerState<ExpertDetailsScreen> createState() => _ExpertDetailsScreenState();
}

class _ExpertDetailsScreenState extends ConsumerState<ExpertDetailsScreen> {
  final _portfolio = TextEditingController();
  final _linkedIn = TextEditingController();
  final _license = TextEditingController();
  final _years = TextEditingController();
  final _specialty = TextEditingController();
  final _notes = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _busy = false;
  ExpertKind _kind = ExpertKind.dietitian;

  @override
  void initState() {
    super.initState();
    _kind = widget.suggestedKind ?? ExpertKind.dietitian;
  }

  @override
  void dispose() {
    _portfolio.dispose();
    _linkedIn.dispose();
    _license.dispose();
    _years.dispose();
    _specialty.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool _looksLikeUrl(String s) =>
      s.isEmpty || s.startsWith('http://') || s.startsWith('https://');

  String? _validateUrl(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // optional
    if (!_looksLikeUrl(s)) return 'Must start with http:// or https://';
    if (s.length < 8) return 'Too short';
    return null;
  }

  String? _validateYears(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // optional
    final n = int.tryParse(s);
    if (n == null) return 'Enter a number';
    if (n < 0 || n > 80) return 'Enter 0–80';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      final signedIn = await ref.read(authRepositoryProvider).isSignedIn();
      if (!signedIn) {
        if (!mounted) return;
        context.go('/signin');
        return;
      }
      final years = int.tryParse(_years.text.trim());
      await ref.read(expertOnboardingRepoProvider).saveExpertDetails(
            specialization: _kind.name,
            portfolioUrl: _portfolio.text.trim().isEmpty ? null : _portfolio.text.trim(),
            linkedinUrl: _linkedIn.text.trim().isEmpty ? null : _linkedIn.text.trim(),
            licenseNo: _license.text.trim().isEmpty ? null : _license.text.trim(),
            yearsExperience: years,
            primarySpecialty: _specialty.text.trim().isEmpty ? null : _specialty.text.trim(),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            submittedAtUtc: DateTime.now().toUtc(),
            status: 'pending',
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expert details submitted for review.')),
      );
      context.go('/expert/approval-status');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save details. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Expert details')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Tell us about your expertise',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text('Provide details to help us verify your profile.',
                            style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 16),

                        Text('Select your expertise',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),

                        SegmentedButton<ExpertKind>(
                          segments: const [
                            ButtonSegment(value: ExpertKind.dietitian, label: Text('Dietitian')),
                            ButtonSegment(value: ExpertKind.fitnessExpert, label: Text('Fitness Expert')),
                            ButtonSegment(value: ExpertKind.healthyMealsProvider, label: Text('Healthy meals provider')),
                          ],
                          selected: {_kind},
                          onSelectionChanged: (set) {
                            if (set.isNotEmpty) setState(() => _kind = set.first);
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _portfolio,
                          decoration: const InputDecoration(labelText: 'Portfolio / Website URL'),
                          validator: _validateUrl,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _linkedIn,
                          decoration: const InputDecoration(labelText: 'LinkedIn / Professional Profile'),
                          validator: _validateUrl,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _license,
                                decoration: const InputDecoration(labelText: 'License / Registration #'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _years,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Years of Experience'),
                                validator: _validateYears,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _specialty,
                          decoration: const InputDecoration(labelText: 'Primary Specialty'),
                          validator: (v) => (v != null && v.trim().length >= 2)
                              ? null
                              : 'Please enter at least 2 characters',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notes,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes / Certifications / Links',
                            helperText: 'Add certs, publications, or verification links.',
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _busy ? null : () => context.go('/expert/approval-status'),
                                child: const Text('Skip for now'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _busy ? null : _save,
                                child: const Text('Save & Continue'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Tip: You can update these details later from your profile.',
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_busy)
              const Positioned.fill(child: IgnorePointer(child: Center(child: CircularProgressIndicator()))),
          ],
        ),
      ),
    );
  }
}

