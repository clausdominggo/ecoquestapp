part of questapp;

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final List<VoucherItem> _vouchers = [];
  bool _loading = true;
  String? _errorMessage;

  final Map<String, Color> _statusColors = const {
    'pending': Color(0xFFF59E0B),
    'active': Color(0xFF0E7A5A),
    'redeemed': Color(0xFF475569),
    'expired': Color(0xFFB91C1C),
  };

  final Map<String, List<VoucherItem>> _grouped = {};

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final items = await ApiClient.getVouchers();
      if (!mounted) return;

      setState(() {
        _vouchers
          ..clear()
          ..addAll(items);
        _rebuildGroups();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _loading = false;
      });
    }
  }

  void _rebuildGroups() {
    _grouped.clear();
    for (final voucher in _vouchers) {
      _grouped.putIfAbsent(voucher.status, () => <VoucherItem>[]).add(voucher);
    }
  }

  Future<void> _openVoucherDetail(VoucherItem voucher) async {
    final updated = await Navigator.push<VoucherItem>(
      context,
      MaterialPageRoute(
        builder: (_) => VoucherQrDetailScreen(voucher: voucher),
      ),
    );

    if (updated == null) return;

    setState(() {
      final index = _vouchers.indexWhere((item) => item.id == updated.id);
      if (index != -1) {
        _vouchers[index] = updated;
        _rebuildGroups();
      }
    });
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Voucher',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Lihat semua voucher kamu berdasarkan status, lalu buka detail QR untuk submit review.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _VoucherSummaryCard(
                          label: 'Pending',
                          value: _vouchers.where((item) => item.isPending).length.toString(),
                          color: _statusColors['pending']!,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _VoucherSummaryCard(
                          label: 'Active',
                          value: _vouchers.where((item) => item.isActive).length.toString(),
                          color: _statusColors['active']!,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _VoucherSummaryCard(
                          label: 'Redeemed',
                          value: _vouchers.where((item) => item.isRedeemed).length.toString(),
                          color: _statusColors['redeemed']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _ErrorState(
                          message: _errorMessage!,
                          onRetry: _loadVouchers,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadVouchers,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                            children: [
                              if (_vouchers.isEmpty)
                                const _EmptyVoucherState(),
                              for (final status in ['pending', 'active', 'redeemed', 'expired']) ...[
                                if ((_grouped[status] ?? []).isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: _statusColors[status]!,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _statusLabel(status),
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: AppPalette.darkGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...(_grouped[status] ?? []).map(
                                    (voucher) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _VoucherCard(
                                        voucher: voucher,
                                        color: _statusColors[status]!,
                                        formatDate: _formatDate,
                                        onTap: () => _openVoucherDetail(voucher),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'active':
        return 'Active';
      case 'redeemed':
        return 'Redeemed';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }
}

class _EmptyVoucherState extends StatelessWidget {
  const _EmptyVoucherState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Column(
        children: [
          Icon(Icons.card_giftcard_outlined, size: 40, color: AppPalette.textMuted),
          SizedBox(height: 10),
          Text(
            'Belum ada voucher',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppPalette.darkGreen,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Selesaikan quest dan submit review untuk mendapat voucher.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppPalette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppPalette.textBody,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.deepGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _VoucherSummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.85),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final VoucherItem voucher;
  final Color color;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  const _VoucherCard({
    required this.voucher,
    required this.color,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.card_giftcard,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          voucher.rewardType,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.darkGreen,
                          ),
                        ),
                      ),
                      _VoucherStatusChip(
                        label: voucher.status.toUpperCase(),
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tier ${voucher.tier} • ${voucher.code}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPalette.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Dibuat ${formatDate(voucher.createdAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _VoucherStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _VoucherStatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
