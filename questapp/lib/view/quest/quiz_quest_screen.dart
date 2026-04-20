part of questapp;

class QuizQuestScreen extends StatefulWidget {
  final Quest quest;
  final List<QuizQuestion> questions;
  final VoidCallback onComplete;

  const QuizQuestScreen({
    required this.quest,
    required this.questions,
    required this.onComplete,
  });

  @override
  State<QuizQuestScreen> createState() => _QuizQuestScreenState();
}

class _QuizQuestScreenState extends State<QuizQuestScreen>
    with SingleTickerProviderStateMixin {
  late QuizSession _session;
  late AnimationController _timerController;
  int _secondsRemaining = 0;
  int? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _session = QuizSession(
      quest: widget.quest,
      questions: widget.questions,
      startTime: DateTime.now(),
    );
    _secondsRemaining = widget.quest.timeLimit;
    _startTimer();
    _timerController = AnimationController(
      duration: Duration(seconds: widget.quest.timeLimit),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _timer.cancel();
          _autoSubmit();
        }
      });
    });
  }

  void _autoSubmit() {
    final currentQuestion = _session.getCurrentQuestion();
    if (currentQuestion != null && !_isAnswered) {
      _session.scoreQuestion(currentQuestion.id, false);
      _session.selectAnswer(currentQuestion.id, -1);
      setState(() {
        _isAnswered = true;
        _isCorrect = false;
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      _goToNextQuestion();
    });
  }

  void _selectAnswer(int index) {
    if (!_isAnswered) {
      setState(() {
        _selectedAnswer = index;
      });
    }
  }

  void _submitAnswer() {
    final currentQuestion = _session.getCurrentQuestion();
    if (currentQuestion == null || _selectedAnswer == null) return;

    final isCorrect = _selectedAnswer == currentQuestion.correctAnswer;
    _session.scoreQuestion(currentQuestion.id, isCorrect);
    _session.selectAnswer(currentQuestion.id, _selectedAnswer!);

    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
    });

    _timer.cancel();
  }

  void _goToNextQuestion() {
    _session.nextQuestion();

    if (_session.isComplete) {
      _completeQuiz();
    } else {
      // Reset untuk soal berikutnya
      setState(() {
        _selectedAnswer = null;
        _isAnswered = false;
        _isCorrect = false;
        _secondsRemaining = widget.quest.timeLimit;
      });
      _timerController.reset();
      _timerController.forward();
      _startTimer();
    }
  }

  void _completeQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestResultScreen(
          quest: widget.quest,
          score: _session.totalScore,
          correctAnswers: _session.correctCount,
          totalQuestions: widget.questions.length,
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
    final currentQuestion = _session.getCurrentQuestion();

    return WillPopScope(
      onWillPop: () async => false, // Prevent back
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppPalette.darkGreen),
            onPressed: () => _showExitConfirm(),
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
                '${_session.currentIndex + 1} dari ${widget.questions.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            // Timer display
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _secondsRemaining <= 10
                            ? Colors.red
                            : AppPalette.deepGreen,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _formatTime(_secondsRemaining),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _secondsRemaining <= 10
                              ? Colors.red
                              : AppPalette.deepGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: currentQuestion == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Progress bar
                  LinearProgressIndicator(
                    value: (_session.currentIndex + 1) / widget.questions.length,
                    minHeight: 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(
                      AppPalette.deepGreen,
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question image (if any)
                          if (currentQuestion.imageUrl != null)
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[100],
                              ),
                              child: Image.network(
                                currentQuestion.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          if (currentQuestion.imageUrl != null)
                            const SizedBox(height: 20),

                          // Question text
                          Text(
                            currentQuestion.question,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.darkGreen,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Answer options
                          ...List.generate(
                            currentQuestion.options.length,
                            (index) {
                              final option = currentQuestion.options[index];
                              final isSelected = _selectedAnswer == index;
                              final isCorrectOption =
                                  index == currentQuestion.correctAnswer;

                              Color bgColor = Colors.white;
                              Color borderColor = Colors.grey[300]!;
                              Color textColor = AppPalette.textBody;

                              if (_isAnswered) {
                                if (isCorrectOption) {
                                  bgColor = const Color(0xFFD1EDDA);
                                  borderColor = const Color(0xFF28A745);
                                  textColor = const Color(0xFF155724);
                                } else if (isSelected && !_isCorrect) {
                                  bgColor = const Color(0xFFF8D7DA);
                                  borderColor = const Color(0xFFDC3545);
                                  textColor = const Color(0xFF721C24);
                                }
                              } else if (isSelected) {
                                bgColor = const Color(0xFFE3F2FD);
                                borderColor = const Color(0xFF2196F3);
                                textColor = const Color(0xFF1565C0);
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  child: InkWell(
                                    onTap: _isAnswered
                                        ? null
                                        : () => _selectAnswer(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        border: Border.all(
                                          color: borderColor,
                                          width: 2,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: borderColor,
                                                width: 2,
                                              ),
                                              color: isSelected
                                                  ? borderColor
                                                  : Colors.transparent,
                                            ),
                                            child: isSelected
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 16,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                          if (_isAnswered && isCorrectOption)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF28A745),
                                              size: 24,
                                            ),
                                          if (_isAnswered &&
                                              isSelected &&
                                              !_isCorrect)
                                            const Icon(
                                              Icons.cancel_outlined,
                                              color: Color(0xFFDC3545),
                                              size: 24,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Explanation (if answered)
                          if (_isAnswered)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _isCorrect
                                    ? const Color(0xFFD1EDDA)
                                    : const Color(0xFFF8D7DA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isCorrect
                                      ? const Color(0xFF28A745)
                                      : const Color(0xFFDC3545),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _isCorrect
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: _isCorrect
                                            ? const Color(0xFF28A745)
                                            : const Color(0xFFDC3545),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isCorrect ? 'Benar!' : 'Salah',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: _isCorrect
                                              ? const Color(0xFF155724)
                                              : const Color(0xFF721C24),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (currentQuestion.explanation.isNotEmpty)
                                    ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        currentQuestion.explanation,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _isCorrect
                                              ? const Color(0xFF155724)
                                              : const Color(0xFF721C24),
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                ],
                              ),
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // Bottom action buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_isAnswered)
                          ElevatedButton(
                            onPressed: _selectedAnswer != null
                                ? _submitAnswer
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedAnswer != null
                                  ? AppPalette.deepGreen
                                  : Colors.grey[300],
                              foregroundColor: _selectedAnswer != null
                                  ? Colors.white
                                  : Colors.grey,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: const Text(
                              'Submit Jawaban',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: _goToNextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.deepGreen,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _session.currentIndex >= widget.questions.length - 1
                                  ? 'Selesai'
                                  : 'Soal Berikutnya',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showExitConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Quest?'),
        content: const Text(
          'Progress Anda akan hilang. Yakin ingin keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjut'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
