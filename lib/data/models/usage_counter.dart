class UsageCounter {
  final String kind;
  final int count;

  const UsageCounter({required this.kind, required this.count});

  factory UsageCounter.fromMap(Map<String, dynamic> m) =>
      UsageCounter(kind: m['kind'], count: (m['count'] as num).toInt());
}
