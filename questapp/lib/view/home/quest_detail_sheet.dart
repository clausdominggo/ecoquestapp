part of questapp;

class QuestDetailSheet extends StatefulWidget {
  final Quest quest;
  final VoidCallback onNavigate;
  final VoidCallback onStart;

  const QuestDetailSheet({
    required this.quest,
    required this.onNavigate,
    required this.onStart,
  });

  @override
  State<QuestDetailSheet> createState() => _QuestDetailSheetState();
}

class _QuestDetailSheetState extends State<QuestDetailSheet> {
  @override
  Widget build(BuildContext context) {
    final quest = widget.quest;
    final isUnlocked = quest.isUnlocked;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Title + Type Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quest.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppPalette.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _QuestTypeBadge(type: quest.type),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4E6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${quest.points} pts',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Status indicator
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isUnlocked ? Icons.check_circle : Icons.lock,
                          size: 20,
                          color: isUnlocked
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  if (quest.description.isNotEmpty) ...[
                    Text(
                      'Deskripsi',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      quest.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppPalette.textBody,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Info grid: Jarak, Radius, Time Limit
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.location_on_outlined,
                          label: 'Jarak Anda',
                          value: '${quest.unlockDistance.toStringAsFixed(1)} m',
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.radio_button_checked,
                          label: 'Radius Quest',
                          value: '${quest.radius} m',
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.timer_outlined,
                          label: 'Time Limit',
                          value: '${(quest.timeLimit / 60).toStringAsFixed(0)} min',
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.refresh_outlined,
                          label: 'Daily Limit',
                          value: '${quest.dailyLimit}x',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Unlock status message
                  if (!isUnlocked)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        border: Border.all(
                          color: const Color(0xFFFCACA9),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bergeraklah lebih dekat untuk unlock quest ini',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFFDC2626),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onNavigate,
                    icon: const Icon(Icons.directions),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E7FF),
                      foregroundColor: const Color(0xFF4F46E5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isUnlocked ? widget.onStart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUnlocked
                          ? AppPalette.deepGreen
                          : Colors.grey[300],
                      foregroundColor: isUnlocked ? Colors.white : Colors.grey,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Mulai Quest',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestTypeBadge extends StatelessWidget {
  final String type;

  const _QuestTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'GPS': (const Color(0xFFFECDD3), const Color(0xFFC41C3B)),
      'AR': (const Color(0xFFDDD6FE), const Color(0xFF6D28D9)),
      'Quiz': (const Color(0xFFFEF3C7), const Color(0xFBB91C08)),
      'Plant ID': (const Color(0xFFD1EDDA), const Color(0xFF155724)),
      'Treasure Hunt': (const Color(0xFFF8D7DA), const Color(0xFF721C24)),
      'Puzzle': (const Color(0xFFE2E3E5), const Color(0xFF383D41)),
    };

    final (bgColor, textColor) = colors[type] ?? colors['GPS']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppPalette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppPalette.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}
