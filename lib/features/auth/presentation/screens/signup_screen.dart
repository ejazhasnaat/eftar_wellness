import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';

/// Modern signup:
/// - Banner + subtext
/// - Google/Apple sign-in
/// - Email signup (Name, Email, Password, optional Phone)
/// - "Set your path" (Getting Healthy vs Wellness Experts)
/// - On success: snackbar + route by path
/// - Inputs: outlined, no fill (respect global InputDecorationTheme)
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

enum _UserPath { seeker, expert }

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();

  bool _obscure = true;
  bool _busy = false;
  _UserPath _path = _UserPath.seeker;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _onGoogle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      // TODO: integrate Google sign-in.
      _notifyAndNavigate();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onApple() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      // TODO: integrate Apple sign-in.
      _notifyAndNavigate();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onEmailSignup() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      // TODO: integrate email signup; capture name/email/password/phone.
      // Optionally attempt location (city/country) via your LocationService later.
      _notifyAndNavigate();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notifyAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully')),
    );
    if (_path == _UserPath.expert) {
      context.go('/onboard/expert');            // Expert onboarding
    } else {
      context.go('/onboard/wellness/body');     // Health seeker onboarding
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner
                      Text(
                        'Welcome to EFTAR',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Join with Google/Apple or continue with email.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onGoogle,
                              icon: const Icon(Icons.g_mobiledata, size: 24),
                              label: const Text('Continue with Google'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onApple,
                              icon: const Icon(Icons.apple, size: 20),
                              label: const Text('Continue with Apple'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: Divider(color: theme.dividerColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('or', style: theme.textTheme.bodySmall),
                        ),
                        Expanded(child: Divider(color: theme.dividerColor)),
                      ]),

                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            Material(
                              elevation: 2,
                              shadowColor: AppTheme.kSoftShadow,
                              borderRadius: BorderRadius.circular(14),
                              child: TextFormField(
                                controller: _name,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(labelText: 'Name'),
                                validator: (v) => (v == null || v.trim().length < 2) ? 'Enter at least 2 characters' : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Material(
                              elevation: 2,
                              shadowColor: AppTheme.kSoftShadow,
                              borderRadius: BorderRadius.circular(14),
                              child: TextFormField(
                                controller: _email,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(labelText: 'Email'),
                                validator: (v) {
                                  final s = (v ?? '').trim();
                                  if (s.isEmpty) return 'Required';
                                  final re = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  return re.hasMatch(s) ? null : 'Enter a valid email';
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Material(
                              elevation: 2,
                              shadowColor: AppTheme.kSoftShadow,
                              borderRadius: BorderRadius.circular(14),
                              child: TextFormField(
                                controller: _password,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) {
                                  final s = (v ?? '').trim();
                                  if (s.length < 8) return 'Use at least 8 characters';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Material(
                              elevation: 2,
                              shadowColor: AppTheme.kSoftShadow,
                              borderRadius: BorderRadius.circular(14),
                              child: TextFormField(
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(labelText: 'Phone (optional)'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        'Set your path:',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),

                      // Tappable outlined radio-cards
                      _PathCard(
                        title: 'Getting Healthy',
                        subtitle: 'Improve Health and Well-being with AI and Wellness Experts.',
                        value: _UserPath.seeker,
                        groupValue: _path,
                        onChanged: (v) => setState(() => _path = v),
                      ),
                      const SizedBox(height: 8),
                      _PathCard(
                        title: 'Wellness Experts',
                        subtitle: 'Support Health Seekers in reaching their wellness goals.',
                        value: _UserPath.expert,
                        groupValue: _path,
                        onChanged: (v) => setState(() => _path = v),
                      ),

                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _onEmailSignup,
                        child: const Text('Create account'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/signin'),
                        child: const Text('Already have an account? Sign in'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_busy)
              const PositionedFill(child: _Busy()),
          ],
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final _UserPath value;
  final _UserPath groupValue;
  final ValueChanged<_UserPath> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: theme.dividerColor),
      borderRadius: BorderRadius.circular(14),
    );
    final selected = value == groupValue;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onChanged(value),
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.transparent, // consistent: no fill
          shape: border,
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Radio<_UserPath>(
              value: value,
              groupValue: groupValue,
              onChanged: (v) => onChanged(v ?? value),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: Center(child: CircularProgressIndicator()));
  }
}

class PositionedFill extends StatelessWidget {
  const PositionedFill({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: child);
  }
}

