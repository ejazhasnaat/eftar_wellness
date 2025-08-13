// lib/features/auth/presentation/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/application/auth_controller.dart';
import '../../../auth/domain/user_path.dart';
import '../../../../core/services/location_service.dart';
import '../widgets/social_buttons.dart';
// Use a package import for the theme extension to avoid fragile relative paths
import 'package:eftar_wellness/app/theme/app_theme.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});
  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  UserPath _path = UserPath.seeker;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose(); _phone.dispose();
    super.dispose();
  }

  Future<void> _doGoogle() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) _goNext();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doApple() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signInWithApple();
      if (mounted) _goNext();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final loc = await LocationService().getCityCountry();
      await ref.read(authRepositoryProvider).signUpWithEmail(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        city: loc.city,
        country: loc.country,
        path: _path,
      );
      if (mounted) _goNext();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _goNext() {
    switch (_path) {
      case UserPath.seeker: context.go('/onboard/seeker'); break;
      case UserPath.expert: context.go('/onboard/expert'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Welcome to EFTAR', style: tt.headlineSmall),
            const SizedBox(height: 6),
            Text('Join with Google/Apple or continue with email.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            SocialButtons(onGoogle: _doGoogle, onApple: _doApple),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Divider(color: cs.outlineVariant)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('or')),
              Expanded(child: Divider(color: cs.outlineVariant)),
            ]),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Email required';
                      if (!s.contains('@') || !s.contains('.')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone (optional)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Set your path:',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface, // black/white per theme
              ),
            ),
            const SizedBox(height: 8),
            _PathTile(
              selected: _path == UserPath.seeker,
              title: 'Getting Healthy',
              subtitle: 'Improve Health and Well-being with AI and Wellness Experts.',
              onTap: () => setState(() => _path = UserPath.seeker),
            ),
            const SizedBox(height: 8),
            _PathTile(
              selected: _path == UserPath.expert,
              title: 'Wellness Experts',
              subtitle: 'Support Health Seekers in reaching their wellness goals.',
              onTap: () => setState(() => _path = UserPath.expert),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _doEmail,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create account'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.push('/signin'),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathTile extends StatelessWidget {
  const _PathTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deco = Theme.of(context).extension<AppDecorations>()!;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(deco.radius),
      child: Container(
        decoration: deco.outlinedTile(selected: selected), // themed outlined style (no fill)
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Force text color to follow theme surface (black in light, white in dark)
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

