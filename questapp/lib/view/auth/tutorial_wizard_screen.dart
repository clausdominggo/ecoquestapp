part of questapp;

class TutorialWizardScreen extends StatefulWidget {
  const TutorialWizardScreen({super.key});

  @override
  State<TutorialWizardScreen> createState() => _TutorialWizardScreenState();
}

class _TutorialWizardScreenState extends State<TutorialWizardScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeTutorial() async {
    await SessionStore.markTutorialAsCompleted();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/quest-map');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F4),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (index) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? AppPalette.deepGreen
                              : AppPalette.textMuted.withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),
                  TextButton(
                    onPressed: _completeTutorial,
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                children: const [
                  _TutorialPage1(),
                  _TutorialPage2(),
                  _TutorialPage3(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppPalette.deepGreen,
                          ),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            color: AppPalette.deepGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_currentPage == 2) {
                          _completeTutorial();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppPalette.deepGreen,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _currentPage == 2 ? 'Mulai Sekarang' : 'Lanjut',
                        style: const TextStyle(fontWeight: FontWeight.w800),
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
}

class _TutorialPage1 extends StatelessWidget {
  const _TutorialPage1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.deepGreen.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.map_outlined,
              size: 60,
              color: AppPalette.deepGreen,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Jelajahi Peta Quest',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppPalette.darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Lihat semua misi di sekitar kamu. Setiap marker menunjukkan jenis quest: AR, GPS, Quiz, Plant ID, Treasure Hunt, atau Puzzle.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppPalette.textMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.deepGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 16,
                      color: AppPalette.deepGreen,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tips:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.deepGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gesekan jari untuk geser peta. Klik marker quest untuk melihat detail. Gunakan tombol filter untuk menampilkan jenis quest tertentu saja.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPalette.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialPage2 extends StatelessWidget {
  const _TutorialPage2();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.deepGreen.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.category_outlined,
              size: 60,
              color: AppPalette.deepGreen,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Macam-Macam Quest',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppPalette.darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Setiap jenis quest memiliki cara bermain yang berbeda:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppPalette.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          ...[
            ('🗺️', 'GPS', 'Gunakan GPS untuk mencapai lokasi quest. Radius unlock akan berubah warna saat sudah cukup dekat.'),
            ('📸', 'AR', 'Ambil foto dengan augmented reality. Arahkan kamera sesuai instruksi untuk menyelesaikan.'),
            ('❓', 'Quiz', 'Jawab pertanyaan benar untuk mendapatkan poin. Tiap pertanyaan memiliki waktu terbatas.'),
            ('🌿', 'Plant ID', 'Identifikasi jenis tanaman menggunakan AI vision. Foto tanaman yang benar untuk lanjut.'),
            ('💎', 'Treasure Hunt', 'Temukan harta karun berdasarkan petunjuk tersembunyi di lokasi quest.'),
            ('🧩', 'Puzzle', 'Pecahkan teka-teki puzzle untuk membuka quest berikutnya.'),
          ].map((item) {
            return Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppPalette.textMuted.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppPalette.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$3,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppPalette.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TutorialPage3 extends StatelessWidget {
  const _TutorialPage3();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.deepGreen.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.card_giftcard_outlined,
              size: 60,
              color: AppPalette.deepGreen,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Voucher & Reward',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppPalette.darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kumpulkan poin dari setiap quest untuk naik tier dan tukar dengan voucher:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppPalette.textMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _RewardCard(
                icon: Icons.emoji_events_outlined,
                tier: 'Iron',
                points: '0 - 99',
                reward: 'Emblem Iron',
              ),
              const SizedBox(height: 10),
              _RewardCard(
                icon: Icons.emoji_events_outlined,
                tier: 'Bronze',
                points: '100 - 249',
                reward: 'Voucher Diskon 10%',
              ),
              const SizedBox(height: 10),
              _RewardCard(
                icon: Icons.emoji_events_outlined,
                tier: 'Silver',
                points: '250 - 499',
                reward: 'Voucher Diskon 20%',
              ),
              const SizedBox(height: 10),
              _RewardCard(
                icon: Icons.emoji_events_outlined,
                tier: 'Gold',
                points: '500+',
                reward: 'Voucher Gratis Produk',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.deepGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outlined,
                      size: 16,
                      color: AppPalette.deepGreen,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Cara Menebus:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.deepGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '1. Kumpulkan poin dari quest\n2. Naik tier dengan poin\n3. Lihat tab Voucher untuk kode diskon\n4. Gunakan di toko partner untuk redeem reward',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPalette.textMuted,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final IconData icon;
  final String tier;
  final String points;
  final String reward;

  const _RewardCard({
    required this.icon,
    required this.tier,
    required this.points,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppPalette.textMuted.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppPalette.deepGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppPalette.darkGreen,
                  ),
                ),
                Text(
                  points,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppPalette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              reward,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppPalette.deepGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
