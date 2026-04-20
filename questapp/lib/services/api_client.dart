part of questapp;

class ApiClient {
  static Future<Iterable<Uri>> _apiBaseCandidates() async {
    final candidates = <Uri>[];

    final customUrl = await SessionStore.getCustomApiUrl();
    if (customUrl != null && customUrl.isNotEmpty) {
      try {
        candidates.add(Uri.parse(customUrl));
      } catch (_) {}
    }

    final primary = Uri.parse(AppConfig.apiBaseUrl);
    candidates.add(primary);
    candidates.add(primary.replace(host: '192.168.0.195'));
    candidates.add(primary.replace(host: '10.0.2.2'));
    candidates.add(primary.replace(host: '127.0.0.1'));
    candidates.add(primary.replace(host: 'localhost'));

    return candidates;
  }

  static Uri _join(Uri base, String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return base.resolve(normalizedPath);
  }

  static bool _isConnectionError(Object error) {
    return error is SocketException || error is TimeoutException;
  }

  static Future<http.Response> _postJsonWithFallbacks(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    Object? lastError;

    for (final base in await _apiBaseCandidates()) {
      try {
        final url = _join(base, path);
        print('🔵 POST REQUEST: $url');
        print('📦 BODY: $body');

        final response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                ...?headers,
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 15));

        print('✅ RESPONSE: ${response.statusCode} - ${response.body}');
        return response;
      } catch (error) {
        print('❌ ERROR at $base: $error');
        if (!_isConnectionError(error)) {
          rethrow;
        }

        lastError = error;
      }
    }

    throw ApiException(
      lastError is SocketException
          ? 'Backend tidak terjangkau dari HP ini. Jika memakai device fisik, jalankan backend di alamat yang bisa diakses HP atau gunakan adb reverse tcp:8000 tcp:8000.'
          : 'Koneksi ke backend timeout. Pastikan server Laravel sedang berjalan dan alamat API benar.',
      statusCode: 0,
    );
  }

  static Future<http.Response> _getWithFallbacks(
    String path, {
    required Map<String, String> headers,
  }) async {
    Object? lastError;

    for (final base in await _apiBaseCandidates()) {
      try {
        return await http
            .get(
              _join(base, path),
              headers: headers,
            )
            .timeout(const Duration(seconds: 15));
      } catch (error) {
        if (!_isConnectionError(error)) {
          rethrow;
        }

        lastError = error;
      }
    }

    throw ApiException(
      lastError is SocketException
          ? 'Backend tidak terjangkau dari HP ini. Jika memakai device fisik, jalankan backend di alamat yang bisa diakses HP atau gunakan adb reverse tcp:8000 tcp:8000.'
          : 'Koneksi ke backend timeout. Pastikan server Laravel sedang berjalan dan alamat API benar.',
      statusCode: 0,
    );
  }

  static Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _postJsonWithFallbacks(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'device_name': 'flutter-mobile',
        'platform': 'mobile',
      },
    );

    if (response.statusCode != 201) {
      throw ApiException(
        _messageFromResponse(response),
        statusCode: response.statusCode,
      );
    }

    return _sessionFromResponse(response.body);
  }

  static Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _postJsonWithFallbacks(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
        'device_name': 'flutter-mobile',
        'platform': 'mobile',
      },
    );

    if (response.statusCode != 200) {
      throw ApiException(
        _messageFromResponse(response),
        statusCode: response.statusCode,
      );
    }

    return _sessionFromResponse(response.body);
  }

  static Future<void> logout() async {
    final session = await SessionStore.readSession();

    if (session == null) {
      return;
    }

    await _postJsonWithFallbacks(
      '/auth/logout',
      body: const {},
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
      },
    );

    await SessionStore.clearSession();
  }

  static Future<List<Quest>> getQuests() async {
    var session = await SessionStore.readSession();

    if (session == null) {
      throw const ApiException('Silakan login ulang.', statusCode: 401);
    }

    var response = await _getWithFallbacks(
      '/quests',
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );

    if (response.statusCode == 401) {
      await _refreshAccessToken(session.refreshToken);
      session = await SessionStore.readSession();

      if (session == null) {
        throw const ApiException('Session tidak tersedia.', statusCode: 401);
      }

      response = await _getWithFallbacks(
        '/quests',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
    }

    if (response.statusCode != 200) {
      throw ApiException(
        _messageFromResponse(response),
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (body['data'] as List<dynamic>? ?? []);

    return data
        .map((item) => Quest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> _refreshAccessToken(String refreshToken) async {
    final response = await _postJsonWithFallbacks(
      '/auth/refresh',
      body: {
        'refresh_token': refreshToken,
        'device_name': 'flutter-mobile',
      },
    );

    if (response.statusCode != 200) {
      await SessionStore.clearSession();
      throw const ApiException(
        'Session expired, login kembali.',
        statusCode: 401,
      );
    }

    final session = _sessionFromResponse(response.body);
    await SessionStore.saveSession(session);
  }

  static AuthSession _sessionFromResponse(String body) {
    final parsed = jsonDecode(body) as Map<String, dynamic>;
    final user = parsed['user'] as Map<String, dynamic>? ?? const {};

    return AuthSession(
      accessToken: parsed['access_token'] as String? ?? '',
      refreshToken: parsed['refresh_token'] as String? ?? '',
      userName: (user['name'] as String?) ?? 'Visitor',
      userRole: (user['role'] as String?) ?? 'visitor',
    );
  }

  static String _messageFromResponse(http.Response response) {
    try {
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      final message = parsed['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }

      return 'Request gagal (${response.statusCode}).';
    } catch (_) {
      return 'Request gagal (${response.statusCode}).';
    }
  }

    static Future<List<QuizQuestion>> getQuizQuestions(int questId) async {
      var session = await SessionStore.readSession();

      if (session == null) {
        throw const ApiException('Silakan login ulang.', statusCode: 401);
      }

      var response = await _getWithFallbacks(
        '/quests/$questId/questions',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (response.statusCode == 401) {
        await _refreshAccessToken(session.refreshToken);
        session = await SessionStore.readSession();

        if (session == null) {
          throw const ApiException('Session tidak tersedia.', statusCode: 401);
        }

        response = await _getWithFallbacks(
          '/quests/$questId/questions',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
        );
      }

      if (response.statusCode != 200) {
        throw ApiException(
          _messageFromResponse(response),
          statusCode: response.statusCode,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (body['data'] as List<dynamic>? ?? []);

      return data
          .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    static Future<List<VoucherItem>> getVouchers() async {
      var session = await SessionStore.readSession();

      if (session == null) {
        throw const ApiException('Silakan login ulang.', statusCode: 401);
      }

      var response = await _getWithFallbacks(
        '/vouchers',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (response.statusCode == 401) {
        await _refreshAccessToken(session.refreshToken);
        session = await SessionStore.readSession();

        if (session == null) {
          throw const ApiException('Session tidak tersedia.', statusCode: 401);
        }

        response = await _getWithFallbacks(
          '/vouchers',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
        );
      }

      if (response.statusCode != 200) {
        throw ApiException(
          _messageFromResponse(response),
          statusCode: response.statusCode,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (body['data'] as List<dynamic>? ?? []);

      return data
          .map((item) => VoucherItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    static Future<VoucherItem> getVoucherDetail(int voucherId) async {
      var session = await SessionStore.readSession();

      if (session == null) {
        throw const ApiException('Silakan login ulang.', statusCode: 401);
      }

      var response = await _getWithFallbacks(
        '/vouchers/$voucherId',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (response.statusCode == 401) {
        await _refreshAccessToken(session.refreshToken);
        session = await SessionStore.readSession();

        if (session == null) {
          throw const ApiException('Session tidak tersedia.', statusCode: 401);
        }

        response = await _getWithFallbacks(
          '/vouchers/$voucherId',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
        );
      }

      if (response.statusCode != 200) {
        throw ApiException(
          _messageFromResponse(response),
          statusCode: response.statusCode,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return VoucherItem.fromJson(body['data'] as Map<String, dynamic>);
    }

    static Future<VoucherItem> submitVoucherReview(
      int voucherId, {
      required int score,
      String? comment,
    }) async {
      var session = await SessionStore.readSession();

      if (session == null) {
        throw const ApiException('Silakan login ulang.', statusCode: 401);
      }

      final initialAccessToken = session.accessToken;

      Future<http.Response> request(String accessToken) => _postJsonWithFallbacks(
        '/vouchers/$voucherId/review',
        body: {
          'score': score,
          'comment': comment,
        },
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      var response = await request(initialAccessToken);

      if (response.statusCode == 401) {
        await _refreshAccessToken(session.refreshToken);
        session = await SessionStore.readSession();

        if (session == null) {
          throw const ApiException('Session tidak tersedia.', statusCode: 401);
        }

        response = await request(session.accessToken);
      }

      if (response.statusCode != 200) {
        throw ApiException(
          _messageFromResponse(response),
          statusCode: response.statusCode,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return VoucherItem.fromJson(body['data'] as Map<String, dynamic>);
    }

    static Future<VoucherItem> redeemVoucher(int voucherId) async {
      var session = await SessionStore.readSession();

      if (session == null) {
        throw const ApiException('Silakan login ulang.', statusCode: 401);
      }

      var response = await _postJsonWithFallbacks(
        '/vouchers/$voucherId/redeem',
        body: const {},
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (response.statusCode == 401) {
        await _refreshAccessToken(session.refreshToken);
        session = await SessionStore.readSession();

        if (session == null) {
          throw const ApiException('Session tidak tersedia.', statusCode: 401);
        }

        response = await _postJsonWithFallbacks(
          '/vouchers/$voucherId/redeem',
          body: const {},
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
        );
      }

      if (response.statusCode != 200) {
        throw ApiException(
          _messageFromResponse(response),
          statusCode: response.statusCode,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return VoucherItem.fromJson(body['data'] as Map<String, dynamic>);
    }

    static Future<Map<String, dynamic>> submitQuestCompletion(
      int questId, {
      required int score,
      required bool isCorrect,
      String? summary,
      bool timedOut = false,
    }) async {
      var session = await SessionStore.readSession();

      if (session == null) {
        throw const ApiException('Silakan login ulang.', statusCode: 401);
      }

      Future<http.Response> requestWithSession(AuthSession sessionValue) {
        return _postJsonWithFallbacks(
          '/quests/$questId/complete',
          body: {
            'score': score,
            'is_correct': isCorrect,
            'summary': summary,
            'timed_out': timedOut,
          },
          headers: {'Authorization': 'Bearer ${sessionValue.accessToken}'},
        );
      }

      var response = await requestWithSession(session);

      if (response.statusCode == 401) {
        await _refreshAccessToken(session.refreshToken);
        session = await SessionStore.readSession();

        if (session == null) {
          throw const ApiException('Session tidak tersedia.', statusCode: 401);
        }

        response = await requestWithSession(session);
      }

      if (response.statusCode != 200) {
        throw ApiException(
          _messageFromResponse(response),
          statusCode: response.statusCode,
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    static Future<UserProfileSummary> getProfileSummary() async {
      var session = await SessionStore.readSession();

      if (session == null) {
        throw const ApiException('Silakan login ulang.', statusCode: 401);
      }

      var response = await _getWithFallbacks(
        '/auth/me',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (response.statusCode == 401) {
        await _refreshAccessToken(session.refreshToken);
        session = await SessionStore.readSession();

        if (session == null) {
          throw const ApiException('Session tidak tersedia.', statusCode: 401);
        }

        response = await _getWithFallbacks(
          '/auth/me',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
        );
      }

      if (response.statusCode != 200) {
        throw ApiException(
          _messageFromResponse(response),
          statusCode: response.statusCode,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return UserProfileSummary.fromJson(body);
    }
}
