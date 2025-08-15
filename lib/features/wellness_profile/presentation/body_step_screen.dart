import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart' show ProviderSubscription;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../application/wellness_controller.dart';
import '../domain/models.dart';

class BodyStepScreen extends ConsumerStatefulWidget {
  const BodyStepScreen({super.key});
  @override
  ConsumerState<BodyStepScreen> createState() => _BodyStepScreenState();
}

enum _BodyInputMode { heightWeight, bmi }

class _BodyStepScreenState extends ConsumerState<BodyStepScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _bmiCtrl = TextEditingController();

  Uint8List? _photoBytes;
  ProviderSubscription<UserWellnessProfile>? _unitsSub;
  _BodyInputMode _mode = _BodyInputMode.heightWeight;

  @override
  void initState() {
    super.initState();
    final s = ref.read(wellnessProfileProvider);

    // Initial text based on current state/units
    _heightCtrl.text = _formatHeightForUnits(s.heightCm, s.units);
    if (s.weightKg != null) {
      _weightCtrl.text = s.units == Units.metric
          ? s.weightKg!.toStringAsFixed(1)
          : (s.weightKg! / 0.45359237).toStringAsFixed(1);
    }
    if (s.bmi != null) _bmiCtrl.text = s.bmi!.toStringAsFixed(1);

    // Decide default input mode from existing values
    final hasHW = (s.heightCm != null && s.weightKg != null);
    final hasBMI = (s.bmi != null);
    _mode = hasBMI && !hasHW ? _BodyInputMode.bmi : _BodyInputMode.heightWeight;

    // Listen safely for unit changes and reformat visible text
    _unitsSub = ref.listenManual<UserWellnessProfile>(
      wellnessProfileProvider,
      (prev, next) {
        if (prev?.units == next.units) return;

        _heightCtrl.text = _formatHeightForUnits(next.heightCm, next.units);

        if (next.units == Units.metric) {
          if (next.weightKg != null) _weightCtrl.text = next.weightKg!.toStringAsFixed(1);
        } else {
          if (next.weightKg != null) {
            _weightCtrl.text = (next.weightKg! / 0.45359237).toStringAsFixed(1);
          }
        }
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _unitsSub?.close();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _bmiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res != null && res.files.isNotEmpty) {
      setState(() => _photoBytes = res.files.first.bytes);
      await ref.read(wellnessProfileProvider.notifier).setPhotoPath(res.files.first.path);
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
      setState(() => _photoBytes = bytes);
      await ref.read(wellnessProfileProvider.notifier).setPhotoPath(file.path);
    }
  }

  double? _toDouble(String s) => double.tryParse(s.trim());

  /// Parse "5'11", "5 11", "5ft 11in" → centimeters.
  double? _parseImperialHeightToCm(String raw) {
    final re = RegExp(
      r'''^\s*(\d+)\s*(?:'|ft|feet)?\s*(\d{1,2})?\s*(?:"|in|inch|inches)?\s*$''',
    );
    final m = re.firstMatch(raw.trim().toLowerCase());
    if (m != null) {
      final ft = int.tryParse(m.group(1) ?? '') ?? 0;
      final inch = int.tryParse(m.group(2) ?? '0') ?? 0;
      final totalInches = ft * 12 + inch;
      if (totalInches <= 0) return null;
      return totalInches * 2.54;
    }
    return null;
  }

  /// Format cm → "5′11″" (imperial) or "175.0" (metric).
  String _formatHeightForUnits(double? heightCm, Units units) {
    if (heightCm == null) return '';
    if (units == Units.metric) return heightCm.toStringAsFixed(1);
    final totalInches = (heightCm / 2.54).round();
    final ft = totalInches ~/ 12;
    final inch = totalInches % 12;
    return "$ft\u2032$inch\u2033"; // 5′11″
  }

  void _clearBmi() {
    final n = ref.read(wellnessProfileProvider.notifier);
    _bmiCtrl.text = '';
    n.setBmi(null);
  }

  void _clearHeightWeight() {
    final n = ref.read(wellnessProfileProvider.notifier);
    _heightCtrl.text = '';
    _weightCtrl.text = '';
    n.setHeightCm(null);
    n.setWeightKg(null);
  }

  void _onModeChanged(_BodyInputMode next) {
    if (_mode == next) return;
    setState(() => _mode = next);
    // Enforce mutual exclusivity at the moment of switching
    if (next == _BodyInputMode.bmi) {
      _clearHeightWeight();
    } else {
      _clearBmi();
    }
  }

  void _validateAndNext(BuildContext context) {
    final s = ref.read(wellnessProfileProvider);
    if (_mode == _BodyInputMode.heightWeight) {
      if (s.heightCm == null || s.weightKg == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both height and weight.')),
        );
        return;
      }
    } else {
      if (s.bmi == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your BMI.')),
        );
        return;
      }
    }
    context.push('/onboard/wellness/goals');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final deco = theme.extension<AppDecorations>();
    final state = ref.watch(wellnessProfileProvider);
    final notifier = ref.read(wellnessProfileProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health info • 1 of 2'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Your basics', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('You can edit this anytime.', style: theme.textTheme.bodyMedium),

          const SizedBox(height: 16),
          // Profile photo: 3 columns (Photo | Text | Buttons stacked)
          Container(
            decoration: deco?.outlinedTile(selected: false),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Photo
                CircleAvatar(
                  radius: 32,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                  child: _photoBytes == null ? Icon(Icons.person, color: cs.onPrimaryContainer) : null,
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profile photo (optional)', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text('Add a quick photo to personalize your plan.',
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                // Buttons (stacked)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FilledButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Take'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text('Gender', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<Sex>(
            segments: const [
              ButtonSegment(value: Sex.male, label: Text('Male')),
              ButtonSegment(value: Sex.female, label: Text('Female')),
              ButtonSegment(value: Sex.preferNot, label: Text('Other')),
            ],
            selected: { state.sex ?? Sex.preferNot },
            onSelectionChanged: (s) => notifier.setSex(s.first),
          ),

          const SizedBox(height: 16),
          Text('Units', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<Units>(
            segments: const [
              ButtonSegment(value: Units.metric, label: Text('Metric')),
              ButtonSegment(value: Units.imperial, label: Text('Imperial')),
            ],
            selected: { state.units },
            onSelectionChanged: (set) {
              final nextUnits = set.first;
              notifier.setUnits(nextUnits);
              _heightCtrl.text = _formatHeightForUnits(state.heightCm, nextUnits);
              if (nextUnits == Units.metric) {
                if (state.weightKg != null) _weightCtrl.text = state.weightKg!.toStringAsFixed(1);
              } else {
                if (state.weightKg != null) _weightCtrl.text = (state.weightKg! / 0.45359237).toStringAsFixed(1);
              }
              setState(() {});
            },
          ),

          const SizedBox(height: 16),
          Text('Body input', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Choose how you want to provide your body metrics.', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          SegmentedButton<_BodyInputMode>(
            segments: const [
              ButtonSegment(value: _BodyInputMode.heightWeight, label: Text('Height/Weight')),
              ButtonSegment(value: _BodyInputMode.bmi, label: Text('BMI')),
            ],
            selected: { _mode },
            onSelectionChanged: (set) => _onModeChanged(set.first),
          ),

          const SizedBox(height: 16),

          // Dynamically show either Height/Weight OR BMI
          if (_mode == _BodyInputMode.heightWeight) ...[
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _heightCtrl,
                  keyboardType: state.units == Units.metric ? TextInputType.number : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: state.units == Units.metric ? 'Height (cm)' : 'Height (ft′ in″)  e.g., 5′11″',
                  ),
                  onChanged: (v) {
                    double? cm;
                    if (state.units == Units.metric) {
                      cm = _toDouble(v);
                    } else {
                      cm = _parseImperialHeightToCm(v);
                    }
                    ref.read(wellnessProfileProvider.notifier).setHeightCm(cm);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: state.units == Units.metric ? 'Weight (kg)' : 'Weight (lb)',
                  ),
                  onChanged: (v) {
                    final kg = state.units == Units.metric
                        ? _toDouble(v)
                        : (_toDouble(v) == null ? null : _toDouble(v)! * 0.45359237);
                    ref.read(wellnessProfileProvider.notifier).setWeightKg(kg);
                  },
                ),
              ),
            ]),
          ] else ...[
            TextFormField(
              controller: _bmiCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'BMI'),
              onChanged: (v) {
                final val = _toDouble(v);
                ref.read(wellnessProfileProvider.notifier).setBmi(val);
              },
            ),
          ],

          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () => context.push('/onboard/wellness/goals'),
                child: const Text('Skip for now'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => _validateAndNext(context),
                child: const Text('Next'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

