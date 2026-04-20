part of questapp;

class _AuthInputField extends StatelessWidget {
  const _AuthInputField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String? value) validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppPalette.darkGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: AppPalette.deepGreen),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD5D9D3), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: const TextStyle(color: AppPalette.textMuted, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD5D9D3), thickness: 1)),
      ],
    );
  }
}

class _SocialLoginButtons extends StatelessWidget {
  const _SocialLoginButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _SocialButton(
          backgroundColor: Color(0xFF1877F2),
          icon: Icons.facebook,
          iconColor: Colors.white,
        ),
        SizedBox(width: 14),
        _SocialButton(
          backgroundColor: Colors.white,
          icon: Icons.g_mobiledata_rounded,
          iconColor: Colors.red,
          borderColor: Color(0xFFE0E0E0),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    this.borderColor,
  });

  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? Colors.transparent),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});

  final double strength;

  @override
  Widget build(BuildContext context) {
    final color = strength < 0.4
        ? Colors.redAccent
        : strength < 0.75
        ? Colors.orange
        : AppPalette.deepGreen;

    final label = strength < 0.4
        ? 'Weak'
        : strength < 0.75
        ? 'Medium'
        : 'Strong';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 8,
            backgroundColor: const Color(0xFFDCE8E0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Password strength: $label',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final bool showTutorial;
  final VoidCallback onComplete;
  final Quest? focusQuest;
  final Position? userLocation;

  const TutorialOverlay({
    required this.child,
    this.showTutorial = false,
    required this.onComplete,
    this.focusQuest,
    this.userLocation,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.showTutorial) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (_step < 2) {
                setState(() => _step++);
              } else {
                widget.onComplete();
              }
            },
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),
        if (_step < 3)
          _TutorialTooltip(
            title: [
              'Filter Quest',
              'Klik Quest',
              'Lokasi Anda',
            ][_step],
            description: [
              'Gunakan tombol Filter untuk menampilkan jenis quest tertentu. Misalnya hanya GPS quest atau Quiz quest saja.',
              'Klik marker quest untuk melihat detail: tipe, poin, dan status unlock. Radius unlock berubah warna saat sudah cukup dekat dari lokasi Anda.',
              'Tombol GPS menunjukkan lokasi akurat Anda. Semakin kecil angka akurasi, semakin presisi. Ini digunakan untuk mengukur radius unlock quest.',
            ][_step],
            position: _step == 0
                ? const Offset(16, 450)
                : _step == 1
                ? const Offset(16, 200)
                : const Offset(16, 400),
          ),
      ],
    );
  }
}

class _TutorialTooltip extends StatelessWidget {
  final String title;
  final String description;
  final Offset position;

  const _TutorialTooltip({
    required this.title,
    required this.description,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppPalette.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppPalette.textMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tap untuk lanjut',
                style: TextStyle(
                  fontSize: 11,
                  color: AppPalette.deepGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
