// lib/features/providers/provider_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderMenuScreen extends StatefulWidget {
  const ProviderMenuScreen({super.key});
  @override
  State<ProviderMenuScreen> createState() => _ProviderMenuScreenState();
}

class _ProviderMenuScreenState extends State<ProviderMenuScreen> {
  final _sb = Supabase.instance.client;
  List<dynamic> menu = [];
  String? providerRowId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final me = _sb.auth.currentUser!.id;
    final row = await _sb
        .from('food_providers')
        .select('id,menu')
        .eq('user_id', me)
        .maybeSingle();

    if (row != null) {
      providerRowId = row['id'] as String;
      menu = (row['menu'] as List?) ?? [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (providerRowId == null) return;
    await _sb
        .from('food_providers')
        .update({'menu': menu})
        .eq('id', providerRowId!); // <-- non-null assert fix
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Menu'), actions: [
        IconButton(onPressed: _save, icon: const Icon(Icons.save)),
      ]),
      body: ListView.builder(
        itemCount: menu.length,
        itemBuilder: (_, i) {
          final item = Map<String, dynamic>.from(menu[i] as Map);
          return ListTile(
            title: Text(item['name'] ?? 'Unnamed'),
            subtitle: Text('Rs ${item['price'] ?? 0}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() => menu.removeAt(i));
              },
            ),
            onTap: () async {
              final nameCtrl =
                  TextEditingController(text: item['name']?.toString() ?? '');
              final priceCtrl =
                  TextEditingController(text: (item['price'] ?? '').toString());
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Edit Item'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        controller: priceCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        item['name'] = nameCtrl.text.trim();
                        item['price'] = double.tryParse(priceCtrl.text) ?? 0;
                        menu[i] = item;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            setState(() => menu.add({'name': 'New Item', 'price': 0})),
        child: const Icon(Icons.add),
      ),
    );
  }
}

