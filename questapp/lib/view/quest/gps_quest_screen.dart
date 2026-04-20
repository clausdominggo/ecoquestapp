part of questapp;

class GpsQuestScreen extends StatefulWidget {
  final Quest quest;
  final VoidCallback onComplete;

  const GpsQuestScreen({
    required this.quest,
    required this.onComplete,
  });

  @override
  State<GpsQuestScreen> createState() => _GpsQuestScreenState();
}

class _GpsQuestScreenState extends State<GpsQuestScreen> {
  final TextEditingController _answerController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _loadingLocation = true;
  bool _submitting = false;
  bool _hasSubmitted = false;
  Position? _currentPosition;
  double? _distanceMeters;

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
      if (!mounted || _hasSubmitted) return;

      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining <= 0) {
        _timer?.cancel();
        _submitQuest(isTimeout: true);
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
        _showSnack('Izin lokasi diperlukan untuk quest GPS.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.quest.latitude,
        widget.quest.longitude,
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _distanceMeters = distance;
        _loadingLocation = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingLocation = false);
      _showSnack('Gagal membaca lokasi saat ini.');
    }
  }

  Future<void> _submitQuest({bool isTimeout = false}) async {
    if (_submitting || _hasSubmitted) return;

    final answer = _answerController.text.trim();
    final isNearTarget = (_distanceMeters ?? double.infinity) <= widget.quest.radius;
    final hasAnswer = answer.isNotEmpty;
    final isCorrect = !isTimeout && isNearTarget && hasAnswer;

    setState(() {
      _submitting = true;
      _hasSubmitted = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestResultScreen(
          quest: widget.quest,
          score: isCorrect ? widget.quest.points : 0,
          correctAnswers: isCorrect ? 1 : 0,
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
    final distanceText = _distanceMeters == null
        ? 'Mencari lokasi...'
        : _formatDistance(_distanceMeters!);
    final isNearTarget = (_distanceMeters ?? double.infinity) <= widget.quest.radius;

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
            const Text(
              'GPS Quest',
              style: TextStyle(
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
              value: _secondsRemaining / widget.quest.timeLimit,
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
                      'Konfirmasi Lokasi Anda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.quest.description.isNotEmpty
                          ? widget.quest.description
                          : 'Datangi titik quest dan selesaikan instruksi di lokasi ini.',
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
                        color: const Color(0xFFF2F7F4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD9E6DE)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _MiniMapMarkerCard(
                                  title: 'Quest Point',
                                  value: '${widget.quest.latitude.toStringAsFixed(5)}, ${widget.quest.longitude.toStringAsFixed(5)}',
                                  icon: Icons.place,
                                  color: AppPalette.deepGreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MiniMapMarkerCard(
                                  title: 'Posisi Anda',
                                  value: _currentPosition == null
                                      ? 'Sedang dibaca'
                                      : '${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}',
                                  icon: Icons.my_location,
                                  color: const Color(0xFF1D4ED8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFDFF1E7), Color(0xFFF9FCF8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFCFE2D9)),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _GridPainter(),
                                  ),
                                ),
                                const Positioned(
                                  left: 20,
                                  top: 20,
                                  child: Icon(
                                    Icons.terrain,
                                    color: Color(0xFF6B8F71),
                                    size: 32,
                                  ),
                                ),
                                Positioned(
                                  left: 32,
                                  top: 72,
                                  child: _MapPin(
                                    label: 'Quest',
                                    color: AppPalette.deepGreen,
                                  ),
                                ),
                                Positioned(
                                  right: 42,
                                  bottom: 38,
                                  child: _MapPin(
                                    label: 'Anda',
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                                Positioned(
                                  left: 110,
                                  right: 90,
                                  top: 88,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: isNearTarget
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatusChip(
                                label: 'Jarak ${distanceText}',
                                color: isNearTarget
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFFFF7ED),
                                textColor: isNearTarget
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF9A3412),
                              ),
                              _StatusChip(
                                label: isNearTarget ? 'Dalam Geofence' : 'Di Luar Geofence',
                                color: isNearTarget
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFFEE2E2),
                                textColor: isNearTarget
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF991B1B),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Instruksi Tugas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        'Temukan objek atau papan informasi di lokasi tujuan. Catat kode, nama, atau jawaban yang diminta kemudian masukkan di form di bawah.',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppPalette.textBody,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _answerController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Jawaban / Kode yang ditemukan',
                        hintText: 'Ketik hasil temuan Anda di sini',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5FAF7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD8E8DE)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _loadingLocation
                                ? Icons.gps_not_fixed
                                : isNearTarget
                                    ? Icons.verified
                                    : Icons.warning_amber,
                            color: _loadingLocation
                                ? AppPalette.deepGreen
                                : isNearTarget
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFB45309),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _loadingLocation
                                  ? 'Membaca lokasi saat ini...'
                                  : isNearTarget
                                      ? 'Lokasi Anda sudah berada di dalam geofence quest.'
                                      : 'Dekatkan diri ke titik quest untuk mengaktifkan submit.',
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: AppPalette.textBody,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loadingLocation || _submitting
                            ? null
                            : () => _submitQuest(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.deepGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          disabledBackgroundColor: Colors.grey[300],
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
                            : const Text(
                                'Submit Jawaban',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

class _MiniMapMarkerCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniMapMarkerCard({
    required this.title,
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7E7DD)),
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
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppPalette.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;
  final Color color;

  const _MapPin({required this.label, required this.color});

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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD2E3D7)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
