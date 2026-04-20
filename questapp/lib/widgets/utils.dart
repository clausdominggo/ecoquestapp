part of questapp;

double calculatePasswordStrength(String password) {
  if (password.isEmpty) {
    return 0;
  }

  var score = 0;

  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[a-z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

  return math.min(score / 6, 1.0);
}
