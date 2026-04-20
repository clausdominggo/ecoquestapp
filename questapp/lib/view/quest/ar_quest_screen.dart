part of questapp;

class ArQuestScreen extends StatefulWidget {
  final Quest quest;
  final VoidCallback onComplete;

  const ArQuestScreen({
    required this.quest,
    required this.onComplete,
  });

  @override
  State<ArQuestScreen> createState() => _ArQuestScreenState();
}

class _ArQuestScreenState extends State<ArQuestScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 0;
  int _trackingFailures = 0;
  bool _submitting = false;
  bool _showFallbackNotice = false;
  bool _trackingLocked = false;
  final List<QuizQuestion> _fallbackQuestions = [
    const QuizQuestion(
      id: 1,
      question: 'Apa yang harus dilakukan saat AR tracking gagal 3 kali?',
      options: [
        'Lanjut tanpa instruksi',
        'Pindah ke Quiz fallback',
        'Tutup aplikasi',
        'Reset GPS device',
      ],
      correctAnswer: 1,
      explanation: 'Jika tracking AR gagal berulang, quest harus lanjut ke fallback quiz agar user tetap bisa menyelesaikan misi.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.quest.timeLimit;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _submitting) return;
      setState(() {
        _secondsRemaining--;
      });
      if (_secondsRemaining <= 0) {
        _timer?.cancel();
        _submitQuest(isTimeout: true);
      }
    });
  }

  void _registerTrackingFailure() {
    if (_trackingLocked || _submitting) return;

    setState(() {
      _trackingFailures++;
    });

    if (_trackingFailures >= 3) {
      _trackingLocked = true;
      _showFallbackNotice = true;
      _timer?.cancel();
      _showSnack('Tracking gagal 3 kali. Beralih ke Quiz fallback.');
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        _openFallbackQuiz();
      });
    }
  }

  Future<void> _openFallbackQuiz() async {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizQuestScreen(
          quest: widget.quest,
          questions: _fallbackQuestions,
          onComplete: () {
            Navigator.pop(context);
            widget.onComplete();
          },
        ),
      ),
    );
  }

  Future<void> _submitQuest({bool isTimeout = false}) async {
    if (_submitting) return;

    setState(() {
      _submitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestResultScreen(
          quest: widget.quest,
          score: isTimeout ? 0 : widget.quest.points,
          correctAnswers: isTimeout ? 0 : 1,
          totalQuestions: 1,
          onBackToMap: () {
            Navigator.pop(context);
            widget.onComplete();
          },
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final progress = _secondsRemaining / widget.quest.timeLimit;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.18,
                      child: CustomPaint(
                        painter: _ArGridPainter(),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.55), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withOpacity(0.18),
                            blurRadius: 40,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          const Icon(
                            Icons.view_in_ar,
                            size: 88,
                            color: Colors.white,
                          ),
                          Positioned(
                            bottom: 24,
                            child: Text(
                              widget.quest.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    left: 24,
                    right: 24,
                    child: Column(
                      children: [
                        const Text(
                          'AR CAMERA FEED',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withOpacity(0.12)),
                          ),
                          child: Text(
                            'Tracking failures: $_trackingFailures / 3',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (_showFallbackNotice) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7).withOpacity(0.96),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Tracking gagal berulang. Sistem akan beralih ke Quiz fallback.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF92400E),
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 44,
            right: 20,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _secondsRemaining <= 10 ? Colors.red : Colors.white,
                  width: 3,
                ),
                color: Colors.black.withOpacity(0.35),
              ),
              child: Center(
                child: Text(
                  _formatTime(_secondsRemaining),
                  style: TextStyle(
                    color: _secondsRemaining <= 10 ? Colors.redAccent : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.quest.type,
                                style: const TextStyle(
                                  color: AppPalette.deepGreen,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Temukan objek AR dan ikuti instruksi yang tampil di kamera.',
                                style: TextStyle(
                                  color: AppPalette.textBody,
                                  height: 1.4,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _registerTrackingFailure,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.signal_wifi_off,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(AppPalette.deepGreen),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _registerTrackingFailure,
                            icon: const Icon(Icons.broken_image_outlined),
                            label: const Text('Tracking Failure'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFB91C1C),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitting ? null : () => _submitQuest(),
                            icon: const Icon(Icons.send),
                            label: Text(_submitting ? 'Memproses...' : 'Submit Jawaban'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.deepGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF60A5FA).withOpacity(0.12)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
