part of questapp;

class PlantIdQuestScreen extends StatefulWidget {
  final Quest quest;
  final VoidCallback onComplete;

  const PlantIdQuestScreen({
    required this.quest,
    required this.onComplete,
  });

  @override
  State<PlantIdQuestScreen> createState() => _PlantIdQuestScreenState();
}

class _PlantIdQuestScreenState extends State<PlantIdQuestScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _hasCaptured = false;
  bool _isAnalyzing = false;
  bool _analysisComplete = false;
  double _confidence = 0;
  String _speciesName = 'Unknown';
  String _analysisMessage = 'Arahkan kamera ke daun, batang, atau bunga untuk memulai identifikasi.';
  String? _referenceImageLabel;
  final double _minimumConfidence = 75;

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
      if (!mounted || _analysisComplete) return;

      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining <= 0) {
        _timer?.cancel();
        _finishWithScore(0);
      }
    });
  }

  void _capturePhoto() {
    if (_isAnalyzing) return;

    setState(() {
      _hasCaptured = true;
      _analysisMessage = 'Foto ditangkap. Siap mengirim gambar ke AI API...';
    });
  }

  Future<void> _analyzePhoto() async {
    if (!_hasCaptured || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _analysisMessage = 'Mengirim gambar ke AI API untuk identifikasi spesies...';
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final candidates = [
      ('Ficus benjamina', 'assets/images/plant_reference_1.png'),
      ('Mangifera indica', 'assets/images/plant_reference_2.png'),
      ('Syzygium polyanthum', 'assets/images/plant_reference_3.png'),
      ('Delonix regia', 'assets/images/plant_reference_4.png'),
    ];
    final random = math.Random();
    final chosen = candidates[random.nextInt(candidates.length)];
    final confidence = 60 + random.nextInt(41);

    setState(() {
      _speciesName = chosen.$1;
      _referenceImageLabel = chosen.$2;
      _confidence = confidence.toDouble();
      _analysisMessage = _confidence >= _minimumConfidence
          ? 'Identifikasi berhasil. Confidence memenuhi threshold minimum.'
          : 'Confidence masih di bawah threshold minimum. Coba ambil foto yang lebih jelas.';
      _isAnalyzing = false;
      _analysisComplete = true;
    });

    if (_confidence >= _minimumConfidence) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        _finishWithScore(widget.quest.points);
      });
    }
  }

  Future<void> _finishWithScore(int score) async {
    if (_analysisComplete && _isAnalyzing) return;

    setState(() {
      _analysisComplete = true;
    });

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestResultScreen(
          quest: widget.quest,
          score: score,
          correctAnswers: score > 0 ? 1 : 0,
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

  @override
  Widget build(BuildContext context) {
    final confidenceOk = _confidence >= _minimumConfidence;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.quest.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Text(
              'Plant ID Quest',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _secondsRemaining <= 10 ? Colors.redAccent : Colors.white,
                  width: 3,
                ),
                color: Colors.white.withOpacity(0.08),
              ),
              child: Center(
                child: Text(
                  _formatTime(_secondsRemaining),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _secondsRemaining <= 10 ? Colors.redAccent : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0B1220), Color(0xFF0F1A2A), Color(0xFF08101B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PlantScanGridPainter(),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 270,
                      height: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.55), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withOpacity(0.15),
                            blurRadius: 34,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                color: const Color(0xFF132331),
                                child: const Center(
                                  child: Icon(
                                    Icons.local_florist,
                                    size: 110,
                                    color: Colors.white12,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'CAMERA PREVIEW',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 22,
                              top: 64,
                              child: _FocusCorner(top: true, left: true),
                            ),
                            Positioned(
                              right: 22,
                              top: 64,
                              child: _FocusCorner(top: true, left: false),
                            ),
                            Positioned(
                              left: 22,
                              bottom: 78,
                              child: _FocusCorner(top: false, left: true),
                            ),
                            Positioned(
                              right: 22,
                              bottom: 78,
                              child: _FocusCorner(top: false, left: false),
                            ),
                            if (_hasCaptured)
                              Positioned(
                                left: 18,
                                right: 18,
                                bottom: 18,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.42),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _analysisMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      height: 1.45,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.97),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(26),
                            topRight: Radius.circular(26),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 24,
                              offset: const Offset(0, -4),
                            ),
                          ],
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
                                        'Capture foto tanaman lalu kirim ke AI API untuk identifikasi spesies.',
                                        style: TextStyle(
                                          color: AppPalette.textBody,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      confidenceOk ? 'OK' : 'WAIT',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: confidenceOk ? const Color(0xFF059669) : const Color(0xFFB45309),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Threshold ${_minimumConfidence.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppPalette.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isAnalyzing ? null : _capturePhoto,
                                    icon: const Icon(Icons.photo_camera_outlined),
                                    label: Text(_hasCaptured ? 'Retake' : 'Capture Foto'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0E7A5A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _hasCaptured && !_isAnalyzing ? _analyzePhoto : null,
                                    icon: _isAnalyzing
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.auto_awesome),
                                    label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppPalette.deepGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (_analysisComplete) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: confidenceOk ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: confidenceOk ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          confidenceOk ? Icons.verified : Icons.warning_amber_rounded,
                                          color: confidenceOk ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _speciesName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: confidenceOk ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Confidence score: ${_confidence.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: confidenceOk ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _analysisMessage,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.45,
                                        color: confidenceOk ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      height: 84,
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.65),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        _referenceImageLabel ?? 'Reference image',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppPalette.textMuted,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      confidenceOk
                                          ? 'Poin quest diberikan karena confidence di atas threshold minimum.'
                                          : 'Perlu foto yang lebih jelas agar poin bisa diberikan.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.45,
                                        color: confidenceOk ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!confidenceOk) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isAnalyzing ? null : _capturePhoto,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[900],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                    ),
                                    child: const Text(
                                      'Capture Ulang',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantScanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E).withOpacity(0.08)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FocusCorner extends StatelessWidget {
  final bool top;
  final bool left;

  const _FocusCorner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Colors.white70, width: 3) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Colors.white70, width: 3) : BorderSide.none,
          left: left ? const BorderSide(color: Colors.white70, width: 3) : BorderSide.none,
          right: !left ? const BorderSide(color: Colors.white70, width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}
