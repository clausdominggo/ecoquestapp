part of questapp;

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userName,
    required this.userRole,
  });

  final String accessToken;
  final String refreshToken;
  final String userName;
  final String userRole;
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.points,
    required this.status,
    this.description = '',
    this.radius = 50,
    this.mode = 'GPS',
    this.timeLimit = 300,
    this.unlockDistance = 0.0,
    this.imageUrl,
    this.dailyLimit = 1,
  });

  final int id;
  final String title;
  final String type;
  final double latitude;
  final double longitude;
  final int points;
  final String status;
  final String description;
  final int radius; // meter
  final String mode; // 'GPS', 'AR', 'Quiz', etc
  final int timeLimit; // detik
  final double unlockDistance; // meter dari user ke quest point
  final String? imageUrl;
  final int dailyLimit;

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isUnlocked => unlockDistance <= radius;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'points': points,
      'status': status,
      'description': description,
      'radius': radius,
      'mode': mode,
      'time_limit': timeLimit,
      'unlock_distance': unlockDistance,
      'image_url': imageUrl,
      'daily_limit': dailyLimit,
    };
  }

  static Quest fromJson(Map<String, dynamic> json) {
    return Quest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? 'Untitled Quest',
      type: (json['type'] as String?) ?? 'Unknown',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      points: (json['points'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'approach_to_unlock',
      description: (json['description'] as String?) ?? '',
      radius: (json['radius'] as num?)?.toInt() ?? 50,
      mode: (json['mode'] as String?) ?? 'GPS',
      timeLimit: (json['time_limit'] as num?)?.toInt() ?? 300,
      unlockDistance: _toDouble(json['unlock_distance'] ?? 0),
      imageUrl: (json['image_url'] as String?),
      dailyLimit: (json['daily_limit'] as num?)?.toInt() ?? 1,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}

  class QuizQuestion {
    const QuizQuestion({
      required this.id,
      required this.question,
      required this.options,
      required this.correctAnswer,
      this.explanation = '',
      this.imageUrl,
    });

    final int id;
    final String question;
    final List<String> options; // 4 pilihan
    final int correctAnswer; // index (0-3)
    final String explanation;
    final String? imageUrl;

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'question': question,
        'options': options,
        'correct_answer': correctAnswer,
        'explanation': explanation,
        'image_url': imageUrl,
      };
    }

    static QuizQuestion fromJson(Map<String, dynamic> json) {
      final options = ((json['options'] as List?) ?? []).cast<String>().toList();
      while (options.length < 4) {
        options.add('');
      }

      return QuizQuestion(
        id: (json['id'] as num?)?.toInt() ?? 0,
        question: (json['question'] as String?) ?? '',
        options: options,
        correctAnswer: (json['correct_answer'] as num?)?.toInt() ?? 0,
        explanation: (json['explanation'] as String?) ?? '',
        imageUrl: (json['image_url'] as String?),
      );
    }
  }

  class QuizSession {
    QuizSession({
      required this.quest,
      required this.questions,
      this.currentIndex = 0,
      this.answers = const {},
      this.scores = const {},
      this.startTime,
    });

    final Quest quest;
    final List<QuizQuestion> questions;
    int currentIndex;
    Map<int, int> answers; // questionId -> selectedAnswer (index)
    Map<int, bool> scores; // questionId -> correct/incorrect
    DateTime? startTime;

    bool get isComplete => currentIndex >= questions.length;
  
    int get correctCount =>
        scores.values.where((v) => v == true).length;
  
    int get totalScore {
      final correctPercentage = correctCount / questions.length;
      return (correctPercentage * quest.points).toInt();
    }

    void selectAnswer(int questionId, int answerIndex) {
      answers[questionId] = answerIndex;
    }

    void scoreQuestion(int questionId, bool isCorrect) {
      scores[questionId] = isCorrect;
    }

    void nextQuestion() {
      if (currentIndex < questions.length - 1) {
        currentIndex++;
      }
    }

    void previousQuestion() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    }

    QuizQuestion? getCurrentQuestion() =>
        currentIndex < questions.length ? questions[currentIndex] : null;
  }

  class VoucherItem {
    const VoucherItem({
      required this.id,
      required this.code,
      required this.tier,
      required this.rewardType,
      required this.status,
      required this.createdAt,
      this.reviewScore,
      this.reviewComment,
    });

    final int id;
    final String code;
    final String tier;
    final String rewardType;
    final String status; // pending, active, redeemed, expired
    final DateTime createdAt;
    final int? reviewScore;
    final String? reviewComment;

    bool get isPending => status.toLowerCase() == 'pending';
    bool get isActive => status.toLowerCase() == 'active';
    bool get isRedeemed => status.toLowerCase() == 'redeemed';
    bool get isExpired => status.toLowerCase() == 'expired';

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'code': code,
        'tier': tier,
        'reward_type': rewardType,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'review_score': reviewScore,
        'review_comment': reviewComment,
      };
    }

    static VoucherItem fromJson(Map<String, dynamic> json) {
      return VoucherItem(
        id: (json['id'] as num?)?.toInt() ?? 0,
        code: (json['code'] as String?) ?? '',
        tier: (json['tier'] as String?) ?? 'Iron',
        rewardType: (json['reward_type'] as String?) ?? '',
        status: (json['status'] as String?) ?? 'pending',
        createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ?? DateTime.now(),
        reviewScore: (json['review_score'] as num?)?.toInt(),
        reviewComment: (json['review_comment'] as String?),
      );
    }

    VoucherItem copyWith({
      String? status,
      int? reviewScore,
      String? reviewComment,
    }) {
      return VoucherItem(
        id: id,
        code: code,
        tier: tier,
        rewardType: rewardType,
        status: status ?? this.status,
        createdAt: createdAt,
        reviewScore: reviewScore ?? this.reviewScore,
        reviewComment: reviewComment ?? this.reviewComment,
      );
    }
  }

  class VoucherReviewData {
    const VoucherReviewData({
      required this.score,
      this.comment,
    });

    final int score;
    final String? comment;
  }

  class UserProfileSummary {
    const UserProfileSummary({
      required this.name,
      required this.email,
      required this.role,
      required this.tier,
      required this.points,
      required this.questsCompleted,
      required this.vouchersPending,
      required this.vouchersActive,
      required this.vouchersRedeemed,
      required this.vouchersExpired,
      required this.vouchersTotal,
      required this.recentActivity,
      this.lastActivityAt,
    });

    final String name;
    final String email;
    final String role;
    final String tier;
    final int points;
    final int questsCompleted;
    final int vouchersPending;
    final int vouchersActive;
    final int vouchersRedeemed;
    final int vouchersExpired;
    final int vouchersTotal;
    final DateTime? lastActivityAt;
    final List<Map<String, dynamic>> recentActivity;

    static UserProfileSummary fromJson(Map<String, dynamic> json) {
      final user = (json['data'] as Map<String, dynamic>? ?? const {});
      final progress = (json['progress'] as Map<String, dynamic>? ?? const {});
      final vouchers = (json['voucher_summary'] as Map<String, dynamic>? ?? const {});
      final activities = (json['recent_activity'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      return UserProfileSummary(
        name: (user['name'] as String?) ?? 'Visitor',
        email: (user['email'] as String?) ?? '-',
        role: (user['role'] as String?) ?? 'visitor',
        tier: (progress['tier'] as String?) ?? 'Iron',
        points: (progress['points'] as num?)?.toInt() ?? 0,
        questsCompleted: (progress['quests_completed'] as num?)?.toInt() ?? 0,
        vouchersPending: (vouchers['pending'] as num?)?.toInt() ?? 0,
        vouchersActive: (vouchers['active'] as num?)?.toInt() ?? 0,
        vouchersRedeemed: (vouchers['redeemed'] as num?)?.toInt() ?? 0,
        vouchersExpired: (vouchers['expired'] as num?)?.toInt() ?? 0,
        vouchersTotal: (vouchers['total'] as num?)?.toInt() ?? 0,
        lastActivityAt: DateTime.tryParse((progress['last_activity_at'] as String?) ?? ''),
        recentActivity: activities,
      );
    }
  }
