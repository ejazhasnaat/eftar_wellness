// lib/features/auth/presentation/signup_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

// Shared enum
import 'package:eftar_wellness/features/onboarding/domain/expert_kind.dart';
// Location helper (requires geolocator + geocoding and platform perms)
import 'package:eftar_wellness/shared/services/location_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _sb = sb.Supabase.instance.client;

  // Single-line form fields
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _busy = false;
  bool _isExpert = false;
  bool _obscurePassword = true; // password eye toggle
  ExpertKind _expertKind = ExpertKind.dietitian;

  // Background-resolved location info (used at submit time)
  String? _geoCity;
  String? _geoCountry;
  String? _geoIsoCountry;

  // Country code selection (fallback: locale → default)
  _CountryCode _cc = const _CountryCode(name: 'Pakistan', iso2: 'PK', dial: '+92', flag: '🇵🇰');

  // Post-action banner
  String? _infoBanner; // when non-null, shows a MaterialBanner with this message

  @override
  void initState() {
    super.initState();
    _detectCountryFromLocale();   // fast, no permissions
    _prefillFromLocationAsync();  // background, permission-based
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  // ---------- Helpers ----------

  void _detectCountryFromLocale() {
    try {
      final lc = WidgetsBinding.instance.platformDispatcher.locale;
      final iso = (lc.countryCode ?? '').toUpperCase();
      if (iso.isEmpty) return;
      final match = _commonCodes.firstWhere(
        (c) => c.iso2.toUpperCase() == iso,
        orElse: () => _cc,
      );
      if (match.iso2 != _cc.iso2) {
        setState(() => _cc = match);
      }
    } catch (_) {/* best-effort */}
  }

  Future<void> _prefillFromLocationAsync() async {
    final result = await LocationService.getCityCountry();
    if (!mounted || result == null) return;
    setState(() {
      _geoCity = (result.city?.trim().isNotEmpty ?? false) ? result.city!.trim() : _geoCity;
      _geoCountry = (result.country?.trim().isNotEmpty ?? false) ? result.country!.trim() : _geoCountry;
      _geoIsoCountry = (result.isoCountryCode?.trim().isNotEmpty ?? false) ? result.isoCountryCode!.trim() : _geoIsoCountry;

      if (_geoIsoCountry != null) {
        final iso = _geoIsoCountry!.toUpperCase();
        final match = _commonCodes.firstWhere(
          (c) => c.iso2.toUpperCase() == iso,
          orElse: () => _cc,
        );
        _cc = match;
      }
    });
  }

  String get _dbRole => _isExpert ? 'expert' : 'user';
  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');
  bool _looksLikeEmail(String s) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);

  /// E.164-like composed from selected dial + local digits
  String get _e164Phone {
    final localDigits = _digitsOnly(_phone.text);
    if (localDigits.isEmpty) return '';
    final dialDigits = _digitsOnly(_cc.dial);
    return '+$dialDigits$localDigits';
  }

  String get _geoStatusLabel {
    if (_geoCity != null && _geoCity!.isNotEmpty && _geoCountry != null && _geoCountry!.isNotEmpty) {
      return '$_geoCity, $_geoCountry';
    }
    if (_geoCountry != null && _geoCountry!.isNotEmpty) {
      return _geoCountry!;
    }
    return 'Tap to set location';
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  String _stringifyError(Object e) {
    try {
      if (e is sb.AuthException) return e.message;
      final t = e.runtimeType.toString();
      if (t.contains('PostgrestException')) return e.toString();
    } catch (_) {}
    return e.toString();
  }

  /// Works even when email confirmation is enabled and `res.user` is null.
  String? _resolveNewUserId(sb.AuthResponse res) {
    final direct = res.user?.id;
    if (direct != null) return direct;
    final sessionUser = sb.Supabase.instance.client.auth.currentUser?.id;
    if (sessionUser != null) return sessionUser;
    return res.session?.user.id;
  }

  /// Fire-and-forget profile upsert. Never throws. Only valid with a session.
  Future<void> _upsertProfileSilently({
    required String uid,
    required String fullName,
    required String role,
    String? city,
    String? country,
  }) async {
    try {
      if (_sb.auth.currentSession == null) {
        debugPrint('profiles upsert skipped (no session)');
        return;
      }
      await _sb.from('profiles').upsert(
        {
          'id': uid,
          'full_name': fullName,
          'role': role,
          if (city != null) 'city': city,
          if (country != null) 'country': country,
        },
        onConflict: 'id',
      );
    } catch (e) {
      final msg = _stringifyError(e);
      // Silence expected RLS noise; log other errors
      if (!msg.contains('row-level security') && !msg.contains('42501')) {
        debugPrint('profiles upsert failed: $msg');
      }
    }
  }

  // ---------- Actions ----------

  Future<void> _signInWithGoogle() async {
    setState(() => _busy = true);
    try {
      await _sb.auth.signInWithOAuth(sb.OAuthProvider.google);
      if (mounted) context.pop(); // guard will redirect
    } on sb.AuthException catch (e) {
      _showSnack(e.message);
    } catch (_) {
      _showSnack('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      // 1) Create auth user; write geo fields & phone in metadata
      final res = await _sb.auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
        data: {
          'full_name': _fullName.text.trim(),
          'role': _dbRole,
          'city': _geoCity,
          'country': _geoCountry,
          'phone': _e164Phone,
          'phone_country': _cc.iso2,
        },
      );

      // Resolve uid robustly across flows
      final uid = _resolveNewUserId(res);
      final hasSession = _sb.auth.currentSession != null;

      if (uid == null || !hasSession) {
        // Confirmation required (most setups). Tell user clearly and go to signin.
        setState(() {
          _infoBanner =
              'We’ve sent a confirmation link to your email. Please verify, then sign in to continue.';
        });
        if (!mounted) return;
        // Go straight to signin to avoid guard ping‑pong.
        context.go('/signin');
        return;
      }

      // 2) Non-blocking profile upsert — only when authenticated
      unawaited(_upsertProfileSilently(
        uid: uid,
        fullName: _fullName.text.trim(),
        role: _dbRole,
        city: _geoCity,
        country: _geoCountry,
      ));

      // Even with a session, many backends still send a verification email.
      setState(() {
        _infoBanner = 'A verification email has been sent. You can continue using the app.';
      });

      // 3) Next route
      if (!mounted) return;
      if (_isExpert) {
        context.go('/expert/details', extra: {'suggestedKind': _expertKind});
      } else {
        context.go('/post-register');
      }
    } on sb.AuthException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      final msg = _stringifyError(e);
      _showSnack(msg.isEmpty ? 'Something went wrong. Please try again.' : msg);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickCountryCode() async {
    final selected = await showModalBottomSheet<_CountryCode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CountryCodeSheet(selected: _cc),
    );
    if (selected != null && mounted) {
      setState(() => _cc = selected);
    }
  }

  Future<void> _openManualLocationDialog() async {
    final result = await showDialog<_ManualGeoResult>(
      context: context,
      builder: (_) => _ManualGeoDialog(
        initialCity: _geoCity,
        initialCountry: _geoCountry,
        initialCode: _cc,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _geoCity = result.city?.trim().isEmpty == true ? null : result.city?.trim();
        _geoCountry = result.country?.trim().isEmpty == true ? null : result.country?.trim();
        _cc = result.code ?? _cc; // align dial to chosen country
      });
    }
  }

  void _dismissBanner() => setState(() => _infoBanner = null);

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final banner = (_infoBanner == null)
        ? const SizedBox.shrink()
        : MaterialBanner(
            content: Text(_infoBanner!),
            leading: const Icon(Icons.info_outline),
            actions: [
              TextButton(onPressed: _dismissBanner, child: const Text('Dismiss')),
            ],
          );

    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _busy,
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _busy ? 0.5 : 1,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Info banner (optional)
                          banner,
                          if (_infoBanner != null) const SizedBox(height: 8),

                          Text('Create your account',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text('Join with Google or continue with email.',
                              style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 20),

                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _signInWithGoogle,
                            icon: const Icon(Icons.g_mobiledata),
                            label: const Text('Continue with Google'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or with email')),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Full name
                              TextFormField(
                                controller: _fullName,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Full name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().length < 2) ? 'Please enter your name' : null,
                              ),
                              const SizedBox(height: 12),

                              // Email
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v != null && _looksLikeEmail(v.trim())) ? null : 'Enter a valid email',
                              ),
                              const SizedBox(height: 12),

                              // Password with eye toggle
                              TextFormField(
                                controller: _password,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                    tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                                  ),
                                ),
                                validator: (v) =>
                                    (v != null && v.length >= 8) ? null : 'Min 8 characters required',
                              ),
                              const SizedBox(height: 12),

                              // Phone (masked) with dial prefix + inline location chip
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Phone field
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: _phone,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        _PhoneMaskFormatter(), // ### ### ####
                                      ],
                                      decoration: InputDecoration(
                                        labelText: 'Phone number',
                                        hintText: '300 123 4567',
                                        border: const OutlineInputBorder(),
                                        prefixIconConstraints:
                                            const BoxConstraints(minWidth: 0, minHeight: 0),
                                        prefixIcon: _DialPrefix(
                                          cc: _cc,
                                          onTap: _pickCountryCode,
                                        ),
                                      ),
                                      validator: (v) {
                                        final digits = _digitsOnly(v ?? '');
                                        if (digits.isEmpty) return null; // optional
                                        if (digits.length < 7) return 'Enter at least 7 digits';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Location chip inline
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: InputChip(
                                        avatar: const Icon(Icons.location_on_outlined, size: 18),
                                        label: Text(_geoStatusLabel, overflow: TextOverflow.ellipsis),
                                        onPressed: _openManualLocationDialog,
                                        onDeleted: (_geoCity != null || _geoCountry != null)
                                            ? () {
                                                setState(() {
                                                  _geoCity = null;
                                                  _geoCountry = null;
                                                  _geoIsoCountry = null;
                                                });
                                              }
                                            : null,
                                        deleteIcon: (_geoCity != null || _geoCountry != null)
                                            ? const Icon(Icons.clear)
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Role radios (your updated copy)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Set your path:',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.colorScheme.outlineVariant),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    RadioListTile<bool>(
                                      value: false,
                                      groupValue: _isExpert,
                                      onChanged: (v) => setState(() => _isExpert = v ?? false),
                                      title: const Text('Getting Healthy'),
                                      subtitle: const Text(
                                        'Improve health and wellbeing with AI and Wellness Experts.',
                                      ),
                                    ),
                                    const Divider(height: 0),
                                    RadioListTile<bool>(
                                      value: true,
                                      groupValue: _isExpert,
                                      onChanged: (v) => setState(() => _isExpert = v ?? true),
                                      title: const Text('Wellness Expert'),
                                      subtitle: const Text(
                                        'Support Health Seekers in reaching their wellness goals.',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: FilledButton(
                                  onPressed: _busy ? null : _submitEmailSignUp,
                                  child: const Text('Create account'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'By continuing, you agree to our Terms & Privacy.',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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

/// Manual city/country dialog (no backend writes; only updates local state).
class _ManualGeoDialog extends StatefulWidget {
  const _ManualGeoDialog({
    required this.initialCity,
    required this.initialCountry,
    required this.initialCode,
  });
  final String? initialCity;
  final String? initialCountry;
  final _CountryCode initialCode;

  @override
  State<_ManualGeoDialog> createState() => _ManualGeoDialogState();
}

class _ManualGeoDialogState extends State<_ManualGeoDialog> {
  final _city = TextEditingController();
  late _CountryCode _code;
  String? _countryName;

  @override
  void initState() {
    super.initState();
    _city.text = widget.initialCity ?? '';
    _countryName = widget.initialCountry;
    _code = widget.initialCode;
  }

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final selected = await showModalBottomSheet<_CountryCode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CountryCodeSheet(selected: _code),
    );
    if (selected != null && mounted) {
      setState(() {
        _code = selected;
        _countryName ??= selected.name; // prefill if empty
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set your location'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _city,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'City (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                    child: InkWell(
                      onTap: _pickCountry,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: Text(_countryName ?? _code.name, overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _pickCountry,
                  icon: Text(_code.flag, style: const TextStyle(fontSize: 18)),
                  label: Text(_code.dial),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<_ManualGeoResult>(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop<_ManualGeoResult>(
              _ManualGeoResult(
                city: _city.text.trim().isEmpty ? null : _city.text.trim(),
                country: (_countryName ?? _code.name),
                code: _code,
              ),
            );
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _ManualGeoResult {
  final String? city;
  final String? country;
  final _CountryCode? code;
  _ManualGeoResult({this.city, this.country, this.code});
}

/// Compact dial code prefix button for the phone TextField.
class _DialPrefix extends StatelessWidget {
  const _DialPrefix({required this.cc, required this.onTap});
  final _CountryCode cc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cc.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(cc.dial, style: theme.textTheme.bodyMedium),
            const Icon(Icons.arrow_drop_down),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

/// Lightweight phone mask: formats digits as `### ### ####`.
class _PhoneMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i == 3 || i == 6) buf.write(' ');
      buf.write(raw[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Value object for a country dial code.
class _CountryCode {
  final String name;
  final String iso2;
  final String dial;
  final String flag;
  const _CountryCode({
    required this.name,
    required this.iso2,
    required this.dial,
    required this.flag,
  });
  @override
  String toString() => '$flag $name ($dial)';
}

/// Country/dial picker (reused in main screen & dialog).
class _CountryCodeSheet extends StatefulWidget {
  const _CountryCodeSheet({required this.selected});
  final _CountryCode selected;

  @override
  State<_CountryCodeSheet> createState() => _CountryCodeSheetState();
}

class _CountryCodeSheetState extends State<_CountryCodeSheet> {
  final _search = TextEditingController();
  late List<_CountryCode> _all;
  late List<_CountryCode> _filtered;

  @override
  void initState() {
    super.initState();
    _all = _commonCodes;
    _filtered = _all;
    _search.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _search.removeListener(_applyFilter);
    _search.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.iso2.toLowerCase().contains(q) ||
              c.dial.replaceAll('+', '').contains(q.replaceAll('+', ''));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search country or code',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (_, i) {
                  final c = _filtered[i];
                  final selected = c.iso2 == widget.selected.iso2;
                  return ListTile(
                    leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                    title: Text('${c.name}  ${c.dial}'),
                    subtitle: Text(c.iso2),
                    trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () => Navigator.of(context).pop<_CountryCode>(c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Curated list; expand as needed.
const List<_CountryCode> _commonCodes = [
  _CountryCode(name: 'Pakistan', iso2: 'PK', dial: '+92', flag: '🇵🇰'),
  _CountryCode(name: 'United States', iso2: 'US', dial: '+1', flag: '🇺🇸'),
  _CountryCode(name: 'United Kingdom', iso2: 'GB', dial: '+44', flag: '🇬🇧'),
  _CountryCode(name: 'India', iso2: 'IN', dial: '+91', flag: '🇮🇳'),
  _CountryCode(name: 'United Arab Emirates', iso2: 'AE', dial: '+971', flag: '🇦🇪'),
  _CountryCode(name: 'Saudi Arabia', iso2: 'SA', dial: '+966', flag: '🇸🇦'),
  _CountryCode(name: 'Canada', iso2: 'CA', dial: '+1', flag: '🇨🇦'),
  _CountryCode(name: 'Australia', iso2: 'AU', dial: '+61', flag: '🇦🇺'),
  _CountryCode(name: 'Bangladesh', iso2: 'BD', dial: '+880', flag: '🇧🇩'),
  _CountryCode(name: 'Malaysia', iso2: 'MY', dial: '+60', flag: '🇲🇾'),
  _CountryCode(name: 'South Africa', iso2: 'ZA', dial: '+27', flag: '🇿🇦'),
  _CountryCode(name: 'Germany', iso2: 'DE', dial: '+49', flag: '🇩🇪'),
  _CountryCode(name: 'France', iso2: 'FR', dial: '+33', flag: '🇫🇷'),
  _CountryCode(name: 'Turkey', iso2: 'TR', dial: '+90', flag: '🇹🇷'),
  _CountryCode(name: 'Indonesia', iso2: 'ID', dial: '+62', flag: '🇮🇩'),
];

