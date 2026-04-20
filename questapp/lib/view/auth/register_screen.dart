part of questapp;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  double get _passwordStrength =>
      calculatePasswordStrength(_passwordController.text);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      final session = await ApiClient.register(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      await SessionStore.saveSession(session);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/tutorial');
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat register.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Register',
      subtitle: 'Create your new account',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _AuthInputField(
              controller: _fullNameController,
              label: 'Full Name',
              hintText: 'Nama lengkap',
              prefixIcon: Icons.person_outline,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Nama lengkap wajib diisi'
                  : null,
            ),
            const SizedBox(height: 14),
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
              controller: _phoneController,
              label: 'Phone Number',
              hintText: '+62 812 3456 7890',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomor telepon wajib diisi';
                }

                if (value.trim().length < 8) {
                  return 'Nomor telepon terlalu pendek';
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
              validator: (value) => (value == null || value.length < 8)
                  ? 'Password minimal 8 karakter'
                  : null,
            ),
            const SizedBox(height: 10),
            _PasswordStrengthBar(strength: _passwordStrength),
            const SizedBox(height: 16),
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
                      'REGISTER',
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
          const Text('Sudah punya akun? '),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text(
              'Login',
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
