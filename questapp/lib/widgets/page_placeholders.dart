part of questapp;

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late Future<UserProfileSummary> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiClient.getProfileSummary();
  }

  String _formatDate(dynamic value) {
    final raw = value?.toString() ?? '';
    final date = DateTime.tryParse(raw);
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfileSummary>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                  const SizedBox(height: 10),
                  const Text(
                    'Gagal memuat profil user',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _profileFuture = ApiClient.getProfileSummary();
                      });
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppPalette.deepGreen),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            final refreshed = ApiClient.getProfileSummary();
            setState(() => _profileFuture = refreshed);
            await refreshed;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E7A5A), Color(0xFF0A5B43)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: AppPalette.deepGreen, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ProfileChip(label: 'Tier ${profile.tier}'),
                        const SizedBox(width: 8),
                        _ProfileChip(label: 'Role ${profile.role}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ProfileStatCard(
                      icon: Icons.stars,
                      label: 'Total Poin',
                      value: '${profile.points}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ProfileStatCard(
                      icon: Icons.task_alt,
                      label: 'Quest Selesai',
                      value: '${profile.questsCompleted}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCFE8DB)),
                ),
                child: Text(
                  'Aktivitas terakhir: ${_formatDate(profile.lastActivityAt)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.darkGreen,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Voucher',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileMiniStat(
                            label: 'Pending',
                            value: '${profile.vouchersPending}',
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ProfileMiniStat(
                            label: 'Active',
                            value: '${profile.vouchersActive}',
                            color: AppPalette.deepGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileMiniStat(
                            label: 'Redeemed',
                            value: '${profile.vouchersRedeemed}',
                            color: const Color(0xFF0EA5E9),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ProfileMiniStat(
                            label: 'Total',
                            value: '${profile.vouchersTotal}',
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Riwayat Aktivitas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (profile.recentActivity.isEmpty)
                      const Text(
                        'Belum ada aktivitas quest.',
                        style: TextStyle(color: AppPalette.textMuted),
                      )
                    else
                      ...profile.recentActivity.map((activity) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F7EF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.history,
                                  size: 18,
                                  color: AppPalette.deepGreen,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (activity['quest_title'] as String?) ?? 'Quest',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppPalette.darkGreen,
                                      ),
                                    ),
                                    Text(
                                      'Score ${(activity['score'] ?? 0)} • ${_formatDate(activity['completed_at'])}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppPalette.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () async {
                  await widget.onLogout();
                },
                style: FilledButton.styleFrom(backgroundColor: AppPalette.deepGreen),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String label;

  const _ProfileChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppPalette.deepGreen, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppPalette.darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppPalette.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProfileMiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
