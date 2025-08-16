// lib/features/onboarding/presentation/expert_details_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_theme.dart'; // AppDecorations extension
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
  // Common
  final _portfolio = TextEditingController();
  final _linkedIn = TextEditingController();
  final _bio = TextEditingController();

  // License / shared
  final _license = TextEditingController();
  final _issuingAuthority = TextEditingController();
  final _licenseExpiry = TextEditingController(); // YYYY-MM-DD
  final _years = TextEditingController();
  final _specialty = TextEditingController();
  final _notes = TextEditingController();

  // Fitness soft criteria
  final _certName = TextEditingController();
  final _certId = TextEditingController();
  final _certExpiry = TextEditingController(); // YYYY-MM-DD
  final _socialHandle = TextEditingController();
  final _followers = TextEditingController();

  // Healthy meals provider
  final _businessName = TextEditingController();
  final _address = TextEditingController();
  bool _delivery = false;
  bool _pickup = false;
  final _deliveryRadiusKm = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  ExpertKind _kind = ExpertKind.dietitian;

  // Profile photo (optional)
  Uint8List? _photoBytes;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _kind = widget.suggestedKind ?? ExpertKind.dietitian;
  }

  @override
  void dispose() {
    _portfolio.dispose();
    _linkedIn.dispose();
    _bio.dispose();
    _license.dispose();
    _issuingAuthority.dispose();
    _licenseExpiry.dispose();
    _years.dispose();
    _specialty.dispose();
    _notes.dispose();
    _certName.dispose();
    _certId.dispose();
    _certExpiry.dispose();
    _socialHandle.dispose();
    _followers.dispose();
    _businessName.dispose();
    _address.dispose();
    _deliveryRadiusKm.dispose();
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

  String? _validateFollowers(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // optional
    final n = int.tryParse(s);
    if (n == null || n < 0) return 'Enter a valid number';
    return null;
  }

  String? _validateDate(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // optional
    final re = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!re.hasMatch(s)) return 'Use YYYY-MM-DD';
    return null;
  }

  Future<void> _pickPhoto() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() {
        _photoBytes = res.files.first.bytes;
        _photoPath = res.files.first.path;
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 1200,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoPath = file.path;
      });
    }
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
      final followers = int.tryParse(_followers.text.trim());
      final deliveryRadius = int.tryParse(_deliveryRadiusKm.text.trim());

      await ref.read(expertOnboardingRepoProvider).saveExpertDetails(
        specialization: _kind.nameKey,
        profilePhotoPath: _photoPath,
        portfolioUrl: _portfolio.text.trim().isEmpty ? null : _portfolio.text.trim(),
        linkedinUrl: _linkedIn.text.trim().isEmpty ? null : _linkedIn.text.trim(),
        bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
        licenseNo: _license.text.trim().isEmpty ? null : _license.text.trim(),
        issuingAuthority: _issuingAuthority.text.trim().isEmpty ? null : _issuingAuthority.text.trim(),
        licenseExpiryIso: _licenseExpiry.text.trim().isEmpty ? null : _licenseExpiry.text.trim(),
        yearsExperience: years,
        primarySpecialty: _specialty.text.trim().isEmpty ? null : _specialty.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        certName: _certName.text.trim().isEmpty ? null : _certName.text.trim(),
        certId: _certId.text.trim().isEmpty ? null : _certId.text.trim(),
        certExpiryIso: _certExpiry.text.trim().isEmpty ? null : _certExpiry.text.trim(),
        socialHandle: _socialHandle.text.trim().isEmpty ? null : _socialHandle.text.trim(),
        followers: followers,
        businessName: _businessName.text.trim().isEmpty ? null : _businessName.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        delivery: _delivery,
        pickup: _pickup,
        deliveryRadiusKm: deliveryRadius,
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
    final deco = theme.extension<AppDecorations>();

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
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Tell us about your expertise',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('Provide details to help us verify your profile.',
                            style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 16),

                        // Profile photo (optional)
                        Container(
                          decoration: deco?.outlinedTile(selected: false),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: cs.primaryContainer,
                                backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                                child: _photoBytes == null
                                    ? Icon(Icons.person, color: cs.onPrimaryContainer)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Profile photo (optional)', style: theme.textTheme.titleSmall),
                                    const SizedBox(height: 4),
                                    Text('Add a clear headshot to help users recognize you.',
                                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Wrap(spacing: 8, children: [
                                OutlinedButton.icon(
                                  onPressed: _busy ? null : _pickPhoto,
                                  icon: const Icon(Icons.upload),
                                  label: Text(_photoBytes == null ? 'Upload' : 'Change'),
                                ),
                                FilledButton.icon(
                                  onPressed: _busy ? null : _takePhoto,
                                  icon: const Icon(Icons.photo_camera_outlined),
                                  label: const Text('Take photo'),
                                ),
                              ]),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text('Select your expertise',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        SegmentedButton<ExpertKind>(
                          segments: const [
                            ButtonSegment(value: ExpertKind.dietitian, label: Text('Dietitian')),
                            ButtonSegment(value: ExpertKind.fitnessExpert, label: Text('Fitness Expert')),
                            ButtonSegment(value: ExpertKind.healthyMealsProvider, label: Text('Healthy meals')),
                          ],
                          selected: {_kind},
                          onSelectionChanged: (set) {
                            if (set.isNotEmpty) setState(() => _kind = set.first);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Common (portfolio/link/bio)
                        Material(
                          elevation: 2,
                          shadowColor: AppTheme.kSoftShadow,
                          borderRadius: BorderRadius.circular(14),
                          child: TextFormField(
                            controller: _portfolio,
                            decoration: const InputDecoration(labelText: 'Portfolio / Website URL'),
                            validator: _validateUrl,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          elevation: 2,
                          shadowColor: AppTheme.kSoftShadow,
                          borderRadius: BorderRadius.circular(14),
                          child: TextFormField(
                            controller: _linkedIn,
                            decoration: const InputDecoration(labelText: 'LinkedIn / Professional Profile'),
                            validator: _validateUrl,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          elevation: 2,
                          shadowColor: AppTheme.kSoftShadow,
                          borderRadius: BorderRadius.circular(14),
                          child: TextFormField(
                            controller: _bio,
                            maxLines: 2,
                            decoration: const InputDecoration(labelText: 'Short bio (optional, ≤ 240 chars)'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Conditional sections
                        if (_kind == ExpertKind.dietitian) ...[
                          _SectionHeader('Dietitian Verification'),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _license,
                                    decoration: const InputDecoration(labelText: 'License / Registration # *'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _issuingAuthority,
                                    decoration: const InputDecoration(labelText: 'Issuing Authority *'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _licenseExpiry,
                                    decoration: const InputDecoration(labelText: 'License Expiry (YYYY-MM-DD)'),
                                    validator: _validateDate,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _years,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Years of Experience'),
                                    validator: _validateYears,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Material(
                            elevation: 2,
                            shadowColor: AppTheme.kSoftShadow,
                            borderRadius: BorderRadius.circular(14),
                            child: TextFormField(
                              controller: _specialty,
                              decoration: const InputDecoration(labelText: 'Primary Specialty'),
                              validator: (v) => (v != null && v.trim().length >= 2) ? null : 'Min 2 chars',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ] else if (_kind == ExpertKind.fitnessExpert) ...[
                          _SectionHeader('Fitness Credentials (softer criteria)'),
                          Material(
                            elevation: 2,
                            shadowColor: AppTheme.kSoftShadow,
                            borderRadius: BorderRadius.circular(14),
                            child: TextFormField(
                              controller: _certName,
                              decoration: const InputDecoration(labelText: 'Certification (ACE/NASM/ISSA/etc.)'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _certId,
                                    decoration: const InputDecoration(labelText: 'Certification ID'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _certExpiry,
                                    decoration: const InputDecoration(labelText: 'Cert Expiry (YYYY-MM-DD)'),
                                    validator: _validateDate,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _socialHandle,
                                    decoration: const InputDecoration(labelText: 'Social handle / URL (optional)'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _followers,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Followers (optional)'),
                                    validator: _validateFollowers,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _years,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Years of Experience'),
                                    validator: _validateYears,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _specialty,
                                    decoration: const InputDecoration(labelText: 'Primary Specialty'),
                                    validator: (v) => (v != null && v.trim().length >= 2) ? null : 'Min 2 chars',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ] else if (_kind == ExpertKind.healthyMealsProvider) ...[
                          _SectionHeader('Healthy Meals Provider'),
                          Material(
                            elevation: 2,
                            shadowColor: AppTheme.kSoftShadow,
                            borderRadius: BorderRadius.circular(14),
                            child: TextFormField(
                              controller: _businessName,
                              decoration: const InputDecoration(labelText: 'Business / Kitchen Name *'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _license,
                                    decoration: const InputDecoration(labelText: 'Food Safety License / Permit # *'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _issuingAuthority,
                                    decoration: const InputDecoration(labelText: 'Issuing Authority *'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _licenseExpiry,
                                    decoration: const InputDecoration(labelText: 'License Expiry (YYYY-MM-DD)'),
                                    validator: _validateDate,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Material(
                                  elevation: 2,
                                  shadowColor: AppTheme.kSoftShadow,
                                  borderRadius: BorderRadius.circular(14),
                                  child: TextFormField(
                                    controller: _address,
                                    decoration: const InputDecoration(labelText: 'Kitchen/Production Address (optional)'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Delivery'),
                                  value: _delivery,
                                  onChanged: (v) => setState(() => _delivery = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Pickup'),
                                  value: _pickup,
                                  onChanged: (v) => setState(() => _pickup = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Material(
                            elevation: 2,
                            shadowColor: AppTheme.kSoftShadow,
                            borderRadius: BorderRadius.circular(14),
                            child: TextFormField(
                              controller: _deliveryRadiusKm,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Delivery Radius (km, optional)'),
                              validator: (v) {
                                final s = (v ?? '').trim();
                                if (s.isEmpty) return null;
                                final n = int.tryParse(s);
                                if (n == null || n < 0 || n > 50) return 'Enter 0–50';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

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
                                child: const Text('Submit for approval'),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

