part of questapp;

class SubmitReviewScreen extends StatefulWidget {
  final VoucherItem voucher;

  const SubmitReviewScreen({
    required this.voucher,
  });

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      _showSnack('Rating bintang wajib diisi.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final updated = await ApiClient.submitVoucherReview(
        widget.voucher.id,
        score: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showSnack('Gagal submit review: $error');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Submit Review',
          style: TextStyle(
            color: AppPalette.darkGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.voucher.rewardType,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Berikan penilaian sebelum voucher diaktifkan. Rating wajib diisi, komentar opsional.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppPalette.textBody,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bintang Penilaian',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final rating = index + 1;
                        final selected = rating <= _rating;
                        return IconButton(
                          onPressed: () => setState(() => _rating = rating),
                          icon: Icon(
                            selected ? Icons.star : Icons.star_border,
                            size: 38,
                            color: selected ? const Color(0xFFF59E0B) : Colors.grey[400],
                          ),
                        );
                      }),
                    ),
                    Center(
                      child: Text(
                        _rating == 0 ? 'Pilih 1-5 bintang' : '$_rating / 5',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _rating == 0 ? Colors.grey[500] : AppPalette.darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _commentController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Komentar (opsional)',
                        hintText: 'Tulis komentar singkat tentang voucher atau proses review',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.deepGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
