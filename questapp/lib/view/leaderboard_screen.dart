part of questapp;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final String _activeTier = 'Bronze';
  final int _currentPoints = 2840;
  final List<_LeaderboardEntry> _entries = const [
    _LeaderboardEntry('Nadia Putri', 'Gold', 4820, 41, 'active'),
    _LeaderboardEntry('Raka Pratama', 'Gold', 4590, 38, 'active'),
    _LeaderboardEntry('Siti Aisyah', 'Silver', 4100, 35, 'inactive'),
    _LeaderboardEntry('Fahri Maulana', 'Silver', 3925, 31, 'active'),
    _LeaderboardEntry('Dewi Lestari', 'Silver', 3710, 30, 'active'),
    _LeaderboardEntry('Andi Saputra', 'Bronze', 3400, 27, 'inactive'),
    _LeaderboardEntry('Maya Sari', 'Bronze', 3310, 25, 'active'),
    _LeaderboardEntry('Bayu Ramadhan', 'Bronze', 3200, 22, 'active'),
    _LeaderboardEntry('Citra Wulandari', 'Iron', 2975, 20, 'inactive'),
    _LeaderboardEntry('Farhan Rizky', 'Iron', 2940, 19, 'active'),
    _LeaderboardEntry('Kirana Ayu', 'Bronze', 2890, 18, 'active', isCurrentUser: true),
    _LeaderboardEntry('Yoga Pratama', 'Iron', 2740, 17, 'inactive'),
    _LeaderboardEntry('Intan Permata', 'Iron', 2680, 15, 'active'),
    _LeaderboardEntry('Hadi Kurniawan', 'Iron', 2510, 14, 'inactive'),
    _LeaderboardEntry('Lina Octavia', 'Bronze', 2470, 13, 'active'),
    _LeaderboardEntry('Rizky Hidayat', 'Iron', 2420, 12, 'inactive'),
    _LeaderboardEntry('Nisa Aulia', 'Iron', 2390, 11, 'active'),
    _LeaderboardEntry('Joko Santoso', 'Iron', 2240, 10, 'inactive'),
    _LeaderboardEntry('Tika Anggraini', 'Iron', 2190, 9, 'active'),
    _LeaderboardEntry('Dimas Alfarizi', 'Iron', 2050, 8, 'inactive'),
  ];

  final Map<String, _TierInfo> _tierInfo = const {
    'Iron': _TierInfo(
      minPoints: 0,
      maxPoints: 999,
      reward: 'Badge dasar, akses quest pemula, dan statistik progres.',
      color: Color(0xFF64748B),
    ),
    'Bronze': _TierInfo(
      minPoints: 1000,
      maxPoints: 2499,
      reward: 'Voucher kecil, quest bonus mingguan, dan item kosmetik.',
      color: Color(0xFFB45309),
    ),
    'Silver': _TierInfo(
      minPoints: 2500,
      maxPoints: 3999,
      reward: 'Voucher prioritas, quest eksklusif, dan akses leaderboard highlight.',
      color: Color(0xFF475569),
    ),
    'Gold': _TierInfo(
      minPoints: 4000,
      maxPoints: 999999,
      reward: 'Reward premium, tier showcase, dan bonus redemption tertinggi.',
      color: Color(0xFFF59E0B),
    ),
  };

  Future<void> _showTierInfo(String tier) async {
    final info = _tierInfo[tier];
    if (info == null) return;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Text(
                '$tier Tier',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.darkGreen,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Range poin: ${info.minPoints} - ${info.maxPoints == 999999 ? '∞' : info.maxPoints}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppPalette.textBody,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                info.reward,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppPalette.textBody,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.deepGreen,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }

  double _progressToNextTier() {
    final current = _tierInfo[_activeTier]!;
    final nextTier = _activeTier == 'Iron'
        ? _tierInfo['Bronze']!
        : _activeTier == 'Bronze'
            ? _tierInfo['Silver']!
            : _activeTier == 'Silver'
                ? _tierInfo['Gold']!
                : current;

    if (_activeTier == 'Gold') return 1.0;

    final span = nextTier.minPoints - current.minPoints;
    final earned = _currentPoints - current.minPoints;
    return (earned / span).clamp(0.0, 1.0);
  }

  String _pointsToNextTier() {
    if (_activeTier == 'Gold') return 'Tier maksimal tercapai';

    final nextMin = _activeTier == 'Iron'
        ? _tierInfo['Bronze']!.minPoints
        : _activeTier == 'Bronze'
            ? _tierInfo['Silver']!.minPoints
            : _tierInfo['Gold']!.minPoints;

    final remaining = nextMin - _currentPoints;
    return remaining <= 0 ? 'Tier berikutnya siap' : '$remaining poin lagi';
  }

  String _formatUserName() {
    return 'Kirana Ayu';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressToNextTier();
    final currentUserName = _formatUserName();
    final currentUser = _entries.firstWhere(
      (entry) => entry.name == currentUserName,
      orElse: () => const _LeaderboardEntry('Kirana Ayu', 'Bronze', 2890, 18, 'active', isCurrentUser: true),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E7A5A), Color(0xFF0A5B43)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Leaderboard & Tier Status',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Pantau posisi kamu, tier saat ini, dan jarak ke tier berikutnya.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                        ),
                        child: Text(
                          '#${_entries.indexWhere((e) => e.isCurrentUser) + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Progress Tier',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _activeTier,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${_formatPoints(_currentPoints)} pts',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _pointsToNextTier(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 9,
                            backgroundColor: Colors.white.withValues(alpha: 0.18),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap badge tier untuk melihat reward yang tersedia.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Current Rank',
                      value: '#${_entries.indexWhere((e) => e.isCurrentUser) + 1}',
                      icon: Icons.leaderboard_outlined,
                      color: const Color(0xFF0E7A5A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Quest Selesai',
                      value: '${currentUser.completedQuests}',
                      icon: Icons.task_alt_outlined,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Tier',
                      value: currentUser.tier,
                      icon: Icons.emoji_events_outlined,
                      color: _tierInfo[currentUser.tier]?.color ?? AppPalette.deepGreen,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: _entries.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  final isUser = entry.isCurrentUser;
                  final tierInfo = _tierInfo[entry.tier]!;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showTierInfo(entry.tier),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFFE8F7EF) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isUser ? AppPalette.deepGreen : Colors.grey[200]!,
                          width: isUser ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isUser ? AppPalette.deepGreen : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isUser ? Colors.white : AppPalette.darkGreen,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        entry.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isUser ? FontWeight.w800 : FontWeight.w700,
                                          color: AppPalette.darkGreen,
                                        ),
                                      ),
                                    ),
                                    if (isUser) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppPalette.deepGreen,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'YOU',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _TierBadge(
                                      tier: entry.tier,
                                      color: tierInfo.color,
                                      onTap: () => _showTierInfo(entry.tier),
                                    ),
                                    _InfoPill(label: '${_formatPoints(entry.points)} pts'),
                                    _InfoPill(label: '${entry.completedQuests} quest'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                entry.statusLabel,
                                style: TextStyle(
                                  color: entry.status == 'active'
                                      ? const Color(0xFF059669)
                                      : AppPalette.textMuted,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Icon(
                                isUser ? Icons.star : Icons.chevron_right,
                                color: isUser ? const Color(0xFFF59E0B) : Colors.grey[400],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _LeaderboardEntry {
  final String name;
  final String tier;
  final int points;
  final int completedQuests;
  final String status;
  final bool isCurrentUser;

  const _LeaderboardEntry(
    this.name,
    this.tier,
    this.points,
    this.completedQuests,
    this.status, {
    this.isCurrentUser = false,
  });

  String get statusLabel => status == 'active' ? 'Active' : 'Inactive';
}

class _TierInfo {
  final int minPoints;
  final int maxPoints;
  final String reward;
  final Color color;

  const _TierInfo({
    required this.minPoints,
    required this.maxPoints,
    required this.reward,
    required this.color,
  });
}

class _TierBadge extends StatelessWidget {
  final String tier;
  final Color color;
  final VoidCallback onTap;

  const _TierBadge({
    required this.tier,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          tier,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;

  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppPalette.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppPalette.darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppPalette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
