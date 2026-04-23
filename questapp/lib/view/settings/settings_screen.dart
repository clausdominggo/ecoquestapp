part of questapp;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiUrlController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiUrlController = TextEditingController();
    _loadCurrentUrl();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUrl() async {
    final url = await SessionStore.getCustomApiUrl();
    setState(() {
      _apiUrlController.text = url ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveApiUrl() async {
    final url = _apiUrlController.text.trim();

    if (url.isEmpty) {
      await SessionStore.clearCustomApiUrl();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom API URL cleared. Using default settings.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      try {
        Uri.parse(url);
        await SessionStore.setCustomApiUrl(url);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API URL saved: $url'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid URL format. Please check and try again.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    setState(() {});
  }

  void _resetToDefaults() async {
    await SessionStore.clearCustomApiUrl();
    setState(() {
      _apiUrlController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to default API settings'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Settings'),
        elevation: 0,
        backgroundColor: AppPalette.deepGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WiFi LAN Connection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.deepGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Jika Anda ingin menghubungkan HP ke backend Laravel melalui ADB reverse, pastikan device terhubung via USB dan jalankan: adb reverse tcp:8000 tcp:8000',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppPalette.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Contoh LAN: http://192.168.1.2:8000/api',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B7355),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Backend URL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppPalette.deepGreen,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _apiUrlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'http://192.168.1.2:8000/api',
                prefixIcon: const Icon(
                  Icons.language,
                  color: AppPalette.deepGreen,
                ),
                suffixIcon: _apiUrlController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppPalette.deepGreen,
                        ),
                        onPressed: () {
                          _apiUrlController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.deepGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveApiUrl,
                child: const Text(
                  'Save URL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.deepGreen),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _resetToDefaults,
                child: const Text(
                  'Reset to Defaults',
                  style: TextStyle(
                    color: AppPalette.deepGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '?? Setup Instructions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B7355),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    '1',
                    'Pastikan HP terhubung ke WiFi yang sama dengan laptop',
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionStep(
                    '2',
                    'Cari IP laptop Anda (biasanya format 192.168.x.x)',
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionStep(
                    '3',
                    'Pastikan backend Laravel sedang berjalan',
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionStep(
                    '4',
                    'Masukkan URL di atas dan tekan Save',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF90CAF9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '?? Alternatif: ADB Reverse',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jika WiFi tidak bisa digunakan, coba ADB reverse di terminal:\n\nadb reverse tcp:8000 tcp:8000\n\nKemudian gunakan URL: http://localhost:8000/api',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1565C0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppPalette.deepGreen,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8B7355)),
          ),
        ),
      ],
    );
  }
}
