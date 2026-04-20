part of questapp;

class SessionStore {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userNameKey = 'user_name';
  static const _userRoleKey = 'user_role';
  static const _customApiUrlKey = 'custom_api_url';

  static Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, session.accessToken);
    await prefs.setString(_refreshTokenKey, session.refreshToken);
    await prefs.setString(_userNameKey, session.userName);
    await prefs.setString(_userRoleKey, session.userRole);
  }

  static Future<AuthSession?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userName: prefs.getString(_userNameKey) ?? 'Visitor',
      userRole: prefs.getString(_userRoleKey) ?? 'visitor',
    );
  }

  static Future<void> updateAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userRoleKey);
  }

  static Future<bool> hasAccessToken() async {
    final session = await readSession();

    return session != null;
  }

  static Future<void> setCustomApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customApiUrlKey, url);
  }

  static Future<String?> getCustomApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customApiUrlKey);
  }

  static Future<void> clearCustomApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customApiUrlKey);
  }
  static Future<bool> hasTutorialBeenCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorialCompleted') ?? false;
  }

  static Future<void> markTutorialAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialCompleted', true);
  }

  static Future<void> resetTutorialCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tutorialCompleted');
  }}
