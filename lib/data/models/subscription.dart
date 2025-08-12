class Subscription {
  final String id, userId, planId, status;
  final DateTime startDate;
  final DateTime? endDate;

  const Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    this.endDate,
  });

  bool get isActive =>
      status == 'active' && (endDate == null || endDate!.isAfter(DateTime.now()));

  factory Subscription.fromMap(Map<String, dynamic> m) => Subscription(
        id: m['id'],
        userId: m['user_id'],
        planId: m['plan_id'],
        status: m['status'],
        startDate: DateTime.parse(m['start_date']),
        endDate: m['end_date'] != null ? DateTime.parse(m['end_date']) : null,
      );
}
