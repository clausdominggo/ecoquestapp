part of questapp;

class QuestResultScreen extends StatefulWidget {
  final Quest quest;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final VoidCallback onBackToMap;

  const QuestResultScreen({
    required this.quest,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.onBackToMap,
  });

  @override
  State<QuestResultScreen> createState() => _QuestResultScreenState();
}

class _QuestResultScreenState extends State<QuestResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  bool _syncingCompletion = true;
  bool _syncFailed = false;
  Map<String, dynamic>? _completionResponse;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCompletion();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _syncCompletion() async {
    try {
      final response = await ApiClient.submitQuestCompletion(
        widget.quest.id,
        score: widget.score,
        isCorrect: widget.score > 0,
        summary: 'Quest ${widget.quest.title} selesai',
        timedOut: widget.score == 0 && widget.correctAnswers == 0,
      );

      if (!mounted) return;
      setState(() {
        _completionResponse = response;
        _syncingCompletion = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _syncingCompletion = false;
        _syncFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.correctAnswers / widget.totalQuestions * 100).toInt();
    final isExcellent = percentage >= 80;
    final isGood = percentage >= 60;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isExcellent
                          ? AppPalette.deepGreen
                          : isGood
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEAB308),
                      isExcellent
                          ? const Color(0xFF0E7A5A)
                          : isGood
                          ? const Color(0xFF059669)
                          : const Color(0xFFC4860E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          isExcellent
                              ? Icons.celebration
                              : isGood
                              ? Icons.check_circle
                              : Icons.trending_up,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isExcellent
                          ? 'Sempurna!'
                          : isGood
                          ? 'Bagus!'
                          : 'Cukup',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.quest.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Score section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_syncingCompletion)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Menyimpan progress ke server...',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppPalette.textBody,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!_syncingCompletion && !_syncFailed && _completionResponse != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF10B981)),
                        ),
                        child: Text(
                          _completionResponse?['voucher_awarded'] != null
                              ? 'Progress tersimpan. Voucher reward baru sudah dibuat.'
                              : 'Progress quest berhasil disimpan ke server.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_syncFailed)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEF4444)),
                        ),
                        child: const Text(
                          'Progress belum tersimpan ke server, tetapi hasil lokal tetap ditampilkan.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7F1D1D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    // Large score display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.score.toString(),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.deepGreen,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'pts',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Akurasi Jawaban',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: widget.correctAnswers / widget.totalQuestions,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              isExcellent
                                  ? AppPalette.deepGreen
                                  : isGood
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEAB308),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppPalette.darkGreen,
                              ),
                            ),
                            Text(
                              '${widget.correctAnswers}/${widget.totalQuestions}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Details cards
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.check_circle_outline,
                            label: 'Jawaban Benar',
                            value: widget.correctAnswers.toString(),
                            color: const Color(0xFF10B981),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.cancel_outlined,
                            label: 'Jawaban Salah',
                            value: '${widget.totalQuestions - widget.correctAnswers}',
                            color: const Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.star,
                            label: 'Quest Type',
                            value: widget.quest.type,
                            color: const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tier info
                    if (isExcellent)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFDCFCE7),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFC8E6C9),
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Achievement Unlocked!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                  Text(
                                    'Kamu berhasil menjawab ${widget.correctAnswers} dari ${widget.totalQuestions} soal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF558B2F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: ElevatedButton(
            onPressed: widget.onBackToMap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.deepGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Kembali ke Peta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppPalette.textBody,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppPalette.darkGreen,
          ),
        ),
      ],
    );
  }
}
