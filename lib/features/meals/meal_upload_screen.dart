import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class MealUploadScreen extends StatefulWidget {
  const MealUploadScreen({super.key});
  @override
  State<MealUploadScreen> createState() => _MealUploadScreenState();
}

class _MealUploadScreenState extends State<MealUploadScreen> {
  final _sb = Supabase.instance.client;
  XFile? picked;

  Future<void> _pick() async {
    picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    setState((){});
  }

  Future<void> _upload() async {
    if (picked == null) return;
    final uid = _sb.auth.currentUser!.id;
    final file = File(picked!.path);
    final ext = p.extension(file.path);
    final key = '$uid/${DateTime.now().millisecondsSinceEpoch}$ext';

    await _sb.storage.from('meal-photos').upload(key, file);
    final signed = await _sb.storage.from('meal-photos').createSignedUrl(key, 60*60*24*7);

    await _sb.from('meals').insert({
      'user_id': uid,
      'image_url': signed,
      'items_detected': [],
      'calories': null, 'protein': null, 'carbs': null, 'fats': null,
      'confidence': null,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal logged')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log a Meal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Expanded(
            child: Center(
              child: picked == null
                ? const Text('Pick a meal photo')
                : Image.file(File(picked!.path), fit: BoxFit.contain),
            ),
          ),
          Row(children: [
            OutlinedButton(onPressed: _pick, child: const Text('Pick Photo')),
            const Spacer(),
            FilledButton(onPressed: _upload, child: const Text('Upload')),
          ]),
        ]),
      ),
    );
  }
}
