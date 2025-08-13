// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../../data/db/app_database.dart';
import '../../../../../app/di/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersStream = ref.watch(userRepositoryProvider).watchAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: StreamBuilder<List<User>>(
        stream: usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load users',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          final items = snapshot.data ?? const <User>[];
          if (items.isEmpty) {
            return const Center(child: Text('No users yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final u = items[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(u.name.isNotEmpty ? u.name[0] : '?'),
                  ),
                  title: Text(u.name),
                  subtitle: Text(u.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        ref.read(userRepositoryProvider).remove(u.id),
                    tooltip: 'Delete',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final repo = ref.read(userRepositoryProvider);
          final id = const Uuid().v4();
          await repo.save(
            User(
              id: id,
              name: 'User ${id.substring(0, 8)}',
              email: '$id@example.com',
              createdAt: DateTime.now(),
              updatedAt: null,
            ),
          );
        },
        label: const Text('Add user'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

