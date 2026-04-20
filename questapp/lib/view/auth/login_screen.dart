part of questapp;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      final session = await ApiClient.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (session.userRole != 'visitor') {
        throw const ApiException('Aplikasi mobile hanya untuk role visitor.');
      }

      await SessionStore.saveSession(session);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/quest-map');
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(error.message);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Terjadi kesalahan saat login.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Welcome Back',
      subtitle: 'Login to your account',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _AuthInputField(
              controller: _emailController,
              label: 'Email',
              hintText: 'user@gmail.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi';
                }

                if (!value.contains('@')) {
                  return 'Format email tidak valid';
                }

                return null;
              },
            ),
            const SizedBox(height: 14),
            _AuthInputField(
              controller: _passwordController,
              label: 'Password',
              hintText: '********',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 8) {
                  return 'Password minimal 8 karakter';
                }

                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  activeColor: AppPalette.deepGreen,
                  onChanged: (value) =>
                      setState(() => _rememberMe = value ?? false),
                ),
                const Text('Remember Me'),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      _showSnack('Endpoint forgot password belum diaktifkan.'),
                  child: const Text(
                    'Forgot Password ?',
                    style: TextStyle(color: AppPalette.deepGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.deepGreen,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'LOGIN',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
            const SizedBox(height: 18),
            const _DividerLabel(text: 'Or continue with'),
            const SizedBox(height: 16),
            const _SocialLoginButtons(),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Belum punya akun? '),
          TextButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/register'),
            child: const Text(
              'Sign up',
              style: TextStyle(
                color: AppPalette.deepGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
