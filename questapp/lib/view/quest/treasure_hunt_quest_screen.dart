part of questapp;

class TreasureHuntQuestScreen extends StatefulWidget {
  final Quest quest;
  final VoidCallback onComplete;

  const TreasureHuntQuestScreen({
    required this.quest,
    required this.onComplete,
  });

  @override
  State<TreasureHuntQuestScreen> createState() => _TreasureHuntQuestScreenState();
}

class _TreasureHuntQuestScreenState extends State<TreasureHuntQuestScreen> {
  final TextEditingController _answerController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 0;
  int _currentClueIndex = 0;
  bool _submitting = false;
  bool _loadingLocation = true;
  double? _distanceMeters;
  String _feedback = '';
  bool _showFeedback = false;
  
  final List<_TreasureClue> _clues = const [
    _TreasureClue(
      title: 'Clue 1',
      instruction: 'Cari papan informasi yang menyebutkan angka tahun berdirinya lokasi ini.',
      expectedAnswer: '2024',
      hint: 'Biasanya ada di dekat pintu masuk atau papan utama.',
      geofenceRadius: 60,
    ),
    _TreasureClue(
      title: 'Clue 2',
      instruction: 'Temukan area yang memiliki simbol daun hijau dan catat kode 3 huruf di bawahnya.',
      expectedAnswer: 'ECO',
      hint: 'Kode sering ada di plakat kecil.',
      geofenceRadius: 50,
    ),
    _TreasureClue(
      title: 'Clue 3',
      instruction: 'Arahkan ke titik kedua lalu cari penanda warna kuning. Masukkan kata kuncinya.',
      expectedAnswer: 'SUN',
      hint: 'Lihat objek yang paling terang di area tersebut.',
      geofenceRadius: 45,
    ),
    _TreasureClue(
      title: 'Clue 4',
      instruction: 'Kumpulkan jawaban terakhir dari area tersembunyi dan selesaikan treasure hunt ini.',
      expectedAnswer: 'ROOT',
      hint: 'Biasanya berada di dekat pohon utama atau area akar.',
      geofenceRadius: 40,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.quest.timeLimit;
    _startTimer();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
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
        _completeWithScore(0);
      }
    });
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => _loadingLocation = false);
        _showSnack('Aktifkan GPS terlebih dahulu.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _loadingLocation = false);
        _showSnack('Izin lokasi diperlukan untuk treasure hunt.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _distanceMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          widget.quest.latitude,
          widget.quest.longitude,
        );
        _loadingLocation = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingLocation = false);
      _showSnack('Gagal membaca lokasi saat ini.');
    }
  }

  Future<void> _submitClueAnswer() async {
    if (_submitting) return;

    final clue = _clues[_currentClueIndex];
    final answer = _answerController.text.trim().toUpperCase();
    final isNearTarget = (_distanceMeters ?? double.infinity) <= clue.geofenceRadius;
    final isCorrect = isNearTarget && answer == clue.expectedAnswer;

    setState(() {
      _showFeedback = true;
      _feedback = isCorrect
          ? 'Benar! Clue ${_currentClueIndex + 1} selesai.'
          : 'Belum tepat. Coba cek hint atau dekatkan diri ke lokasi clue.';
      _submitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (isCorrect) {
      if (_currentClueIndex >= _clues.length - 1) {
        _completeWithScore(widget.quest.points);
      } else {
        setState(() {
          _currentClueIndex++;
          _answerController.clear();
          _showFeedback = false;
          _feedback = '';
          _submitting = false;
        });
      }
    } else {
      setState(() {
        _submitting = false;
      });
    }
  }

  Future<void> _completeWithScore(int score) async {
    setState(() {
      _submitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestResultScreen(
          quest: widget.quest,
          score: score,
          correctAnswers: score > 0 ? _clues.length : 0,
          totalQuestions: _clues.length,
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

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final clue = _clues[_currentClueIndex];
    final isNearTarget = (_distanceMeters ?? double.infinity) <= clue.geofenceRadius;
    final progress = (_currentClueIndex + 1) / _clues.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppPalette.darkGreen),
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
                color: AppPalette.darkGreen,
              ),
            ),
            Text(
              '${clue.title} • ${_currentClueIndex + 1}/${_clues.length}',
              style: const TextStyle(
                fontSize: 12,
                color: AppPalette.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _secondsRemaining <= 10 ? Colors.red : AppPalette.deepGreen,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  _formatTime(_secondsRemaining),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _secondsRemaining <= 10 ? Colors.red : AppPalette.deepGreen,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(AppPalette.deepGreen),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Treasure Hunt Sequence',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selesaikan semua clue secara berurutan. Setiap clue memiliki lokasi geofence tersendiri.',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppPalette.textBody,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F7F5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD6E3DA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clue.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppPalette.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            clue.instruction,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: AppPalette.textBody,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _TreasureInfoCard(
                                  icon: Icons.location_on_outlined,
                                  label: 'Clue Geofence',
                                  value: '${clue.geofenceRadius} m',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _TreasureInfoCard(
                                  icon: Icons.flag_outlined,
                                  label: 'Progress',
                                  value: '${_currentClueIndex + 1}/${_clues.length}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF7ED), Color(0xFFFEFCE8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF4D9A0)),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(child: CustomPaint(painter: _TreasureGridPainter())),
                          Positioned(
                            top: 18,
                            left: 18,
                            child: Icon(Icons.map_outlined, size: 36, color: const Color(0xFFB45309).withOpacity(0.6)),
                          ),
                          Positioned(
                            left: 34,
                            top: 74,
                            child: _TreasurePin(
                              label: 'Clue ${_currentClueIndex + 1}',
                              color: const Color(0xFFB45309),
                            ),
                          ),
                          Positioned(
                            right: 32,
                            bottom: 36,
                            child: _TreasurePin(
                              label: 'You',
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          Positioned(
                            left: 102,
                            right: 84,
                            top: 88,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: isNearTarget ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusChip(
                          label: _loadingLocation ? 'Membaca lokasi...' : 'Jarak ${_distanceMeters == null ? '-' : _formatDistance(_distanceMeters!)}',
                          color: isNearTarget ? const Color(0xFFD1FAE5) : const Color(0xFFFFF7ED),
                          textColor: isNearTarget ? const Color(0xFF065F46) : const Color(0xFF9A3412),
                        ),
                        _StatusChip(
                          label: isNearTarget ? 'Geofence aktif' : 'Belum masuk geofence',
                          color: isNearTarget ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                          textColor: isNearTarget ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        labelText: 'Jawaban clue',
                        hintText: 'Masukkan kata, kode, atau angka yang ditemukan',
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_showFeedback)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _feedback.startsWith('Benar') ? const Color(0xFFD1EDDA) : const Color(0xFFF8D7DA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _feedback.startsWith('Benar') ? const Color(0xFF28A745) : const Color(0xFFDC3545),
                          ),
                        ),
                        child: Text(
                          _feedback,
                          style: TextStyle(
                            color: _feedback.startsWith('Benar') ? const Color(0xFF155724) : const Color(0xFF721C24),
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hint',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppPalette.deepGreen,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            clue.hint,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: AppPalette.textBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loadingLocation || _submitting ? null : _submitClueAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.deepGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _currentClueIndex >= _clues.length - 1 ? 'Submit Final Clue' : 'Submit Clue',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreasureClue {
  final String title;
  final String instruction;
  final String expectedAnswer;
  final String hint;
  final int geofenceRadius;

  const _TreasureClue({
    required this.title,
    required this.instruction,
    required this.expectedAnswer,
    required this.hint,
    required this.geofenceRadius,
  });
}

class _TreasureInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TreasureInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF2E4C5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFFB45309)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppPalette.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _TreasurePin extends StatelessWidget {
  final String label;
  final Color color;

  const _TreasurePin({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.location_pin, size: 42, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppPalette.darkGreen,
          ),
        ),
      ],
    );
  }
}

class _TreasureGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF2C97D).withOpacity(0.35)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 26) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
