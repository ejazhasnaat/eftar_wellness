// lib/features/appointments/book_appointment_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // <-- NEW
import '../../core/feature_gate.dart';
import 'appointment_repo.dart';

class BookAppointmentSheet extends ConsumerStatefulWidget {
  final String expertUserId;
  const BookAppointmentSheet({super.key, required this.expertUserId});

  @override
  ConsumerState<BookAppointmentSheet> createState() =>
      _BookAppointmentSheetState();
}

class _BookAppointmentSheetState
    extends ConsumerState<BookAppointmentSheet> {
  DateTime when = DateTime.now().add(const Duration(hours: 2));
  String kind = 'video';
  bool useFree = true;

  @override
  Widget build(BuildContext context) {
    final gate = ref.read(featureGateProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              const Text('Book Appointment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const Spacer(),
              DropdownButton<String>(
                value: kind,
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('Text')),
                  DropdownMenuItem(value: 'voice', child: Text('Voice')),
                  DropdownMenuItem(value: 'video', child: Text('Video')),
                ],
                onChanged: (v) => setState(() => kind = v!),
              ),
            ]),
            const SizedBox(height: 8),
            SwitchListTile(
              value: useFree,
              onChanged: (v) => setState(() => useFree = v),
              title: const Text('Use free monthly quota (if available)'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                await gate.refresh();
                if (useFree) {
                  final (ok, _) = await gate.canBookFreeAppointment();
                  if (!ok && mounted) {
                    // Navigate to full-screen paywall instead of bottom sheet
                    context.push('/paywall'
                        '?h=Free%20quota%20used'
                        '&b=Upgrade%20to%20Premium%20for%20unlimited%20expert%20sessions.'
                        '&cta=https%3A%2F%2Fyour-checkout-link');
                    return;
                  }
                }
                final appt = await AppointmentRepo().book(
                  expertUserId: widget.expertUserId,
                  kind: kind,
                  when: when,
                  durationMin: 20,
                  freeIfAvailable: useFree,
                );
                if (useFree) {
                  await gate.consumeFreeAppointment();
                }
                if (!mounted) return;
                Navigator.pop(context, appt);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment booked')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

