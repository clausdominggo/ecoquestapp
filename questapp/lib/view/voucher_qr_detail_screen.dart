part of questapp;

class VoucherQrDetailScreen extends StatefulWidget {
  final VoucherItem voucher;

  const VoucherQrDetailScreen({
    required this.voucher,
  });

  @override
  State<VoucherQrDetailScreen> createState() => _VoucherQrDetailScreenState();
}

class _VoucherQrDetailScreenState extends State<VoucherQrDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final voucher = widget.voucher;
    final isPending = voucher.isPending;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'QR Voucher Detail',
          style: TextStyle(
            color: AppPalette.darkGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
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
                              Text(
                                voucher.rewardType,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppPalette.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tier ${voucher.tier} • ${voucher.code}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppPalette.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusPill(
                          label: voucher.status.toUpperCase(),
                          color: isPending ? const Color(0xFFF59E0B) : AppPalette.deepGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _QrPatternPainter(),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black, width: 3),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _FakeQrPainter(),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: 42,
                                          height: 42,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: Icon(
                                            Icons.qr_code_2,
                                            color: isPending ? Colors.black54 : AppPalette.deepGreen,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (isPending)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.52),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        'PENDING\nSubmit review untuk mengaktifkan',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isPending
                          ? 'QR ini belum aktif. Setelah review dikirim, voucher akan berubah menjadi Active dan bisa dipakai staff.'
                          : 'QR aktif dan siap dipindai oleh staff tanpa watermark.',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: AppPalette.textBody,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _VoucherDetailRow(label: 'Status', value: voucher.status),
                    const SizedBox(height: 8),
                    _VoucherDetailRow(label: 'Dibuat', value: _formatDate(voucher.createdAt)),
                    if (voucher.reviewScore != null) ...[
                      const SizedBox(height: 8),
                      _VoucherDetailRow(label: 'Review Score', value: '${voucher.reviewScore}/5'),
                    ],
                    if ((voucher.reviewComment ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          voucher.reviewComment!,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.55,
                            color: AppPalette.textBody,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              if (isPending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final updated = await Navigator.push<VoucherItem>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubmitReviewScreen(voucher: voucher),
                        ),
                      );

                      if (!mounted || updated == null) return;
                      Navigator.pop(context, updated);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.deepGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Submit Review',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPalette.deepGreen,
                    side: const BorderSide(color: AppPalette.deepGreen),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _VoucherDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _VoucherDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppPalette.textMuted,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppPalette.darkGreen,
          ),
        ),
      ],
    );
  }
}

class _QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FakeQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final cell = size.width / 9;

    final pattern = [
      [1, 1, 1, 0, 1, 0, 1, 1, 1],
      [1, 0, 1, 0, 1, 0, 1, 0, 1],
      [1, 1, 1, 1, 0, 1, 1, 1, 1],
      [0, 0, 1, 1, 1, 0, 1, 0, 0],
      [1, 1, 0, 0, 1, 0, 0, 1, 1],
      [1, 0, 1, 1, 0, 1, 1, 0, 1],
      [1, 1, 1, 0, 1, 0, 1, 1, 1],
      [1, 0, 1, 1, 1, 1, 1, 0, 1],
      [1, 1, 1, 0, 1, 0, 1, 1, 1],
    ];

    for (var row = 0; row < pattern.length; row++) {
      for (var col = 0; col < pattern[row].length; col++) {
        if (pattern[row][col] == 1) {
          final rect = Rect.fromLTWH(col * cell, row * cell, cell, cell);
          canvas.drawRect(rect.deflate(1.5), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
