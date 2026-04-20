part of questapp;

class QuestMapScreen extends StatefulWidget {
  const QuestMapScreen({super.key});

  @override
  State<QuestMapScreen> createState() => _QuestMapScreenState();
}

class _QuestMapScreenState extends State<QuestMapScreen> {
  final Set<String> _selectedTypes = {
    'AR',
    'GPS',
    'Quiz',
    'Plant ID',
    'Treasure Hunt',
    'Puzzle',
  };
  final List<Quest> _allQuests = [];
  final List<Quest> _visibleQuests = [];

  int _tabIndex = 0;
  bool _loading = true;
  String _statusFilter = 'all';
  double? _gpsAccuracyMeters;
  bool _locatingCurrentLocation = false;
  StreamSubscription<Position>? _gpsSubscription;
  WebViewController? _webViewController;
  bool _webViewReady = false;
  Map<String, dynamic>? _pendingCurrentLocation;
  bool _showMapTutorial = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _startGpsMonitoring();
    await _loadQuestData();
    await _setupMap();
    await _checkFirstTimeMap();
  }

  Future<void> _checkFirstTimeMap() async {
    final mapTutorialDone = await SessionStore.readSession()
        .then((session) => session != null);
    if (!mounted) return;
    if (mapTutorialDone) {
      setState(() => _showMapTutorial = true);
    }
  }

  Future<void> _startGpsMonitoring() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    _gpsSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ),
        ).listen((position) {
          if (!mounted) return;
          setState(() {
            _gpsAccuracyMeters = position.accuracy;
          });
        });
  }

  Future<void> _loadQuestData() async {
    setState(() => _loading = true);

    try {
      final quests = await ApiClient.getQuests();
      _allQuests
        ..clear()
        ..addAll(quests);
      _applyFilters();
    } on ApiException catch (error) {
      if (!mounted) return;

      if (error.statusCode == 401) {
        await SessionStore.clearSession();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      _showSnack(error.message);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Gagal memuat data quest.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _setupMap() async {
    final html = await rootBundle.loadString(AppAssets.mapHtml);
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'QuestMarkerTap',
        onMessageReceived: (message) {
          final raw = message.message;

          try {
            final parsed = jsonDecode(raw) as Map<String, dynamic>;
            final quest = Quest.fromJson(parsed);
            _showQuestBottomSheet(quest);
          } catch (_) {
            _showSnack('Data marker tidak valid.');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _webViewReady = true;
            _pushMarkersToMap();
            _pushCurrentLocationToMap();
          },
        ),
      )
      ..loadHtmlString(html);

    setState(() {
      _webViewController = controller;
    });
  }

  void _applyFilters() {
    _visibleQuests
      ..clear()
      ..addAll(
        _allQuests.where((quest) {
          final typeAllowed = _selectedTypes.contains(quest.type);
          final statusAllowed = _statusFilter == 'all'
              ? true
              : _statusFilter == 'completed'
              ? quest.isCompleted
              : !quest.isCompleted;

          return typeAllowed && statusAllowed;
        }),
      );

    _pushMarkersToMap();
  }

  void _pushMarkersToMap() {
    if (!_webViewReady || _webViewController == null) {
      return;
    }

    final payload = jsonEncode(
      _visibleQuests.map((item) => item.toJson()).toList(),
    );

    _webViewController!.runJavaScript('window.setQuestMarkers($payload);');
  }

  void _pushCurrentLocationToMap() {
    if (!_webViewReady || _webViewController == null) {
      return;
    }

    final location = _pendingCurrentLocation;

    if (location == null) {
      return;
    }

    final payload = jsonEncode(location);
    _webViewController!.runJavaScript('window.setCurrentLocationMarker($payload);');
  }

  Future<Position?> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _showSnack('Aktifkan GPS terlebih dahulu.');
      return null;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showSnack('Izin lokasi diperlukan.');
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack('Izin lokasi ditolak permanen. Aktifkan di pengaturan.');
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<void> _showCurrentLocationOnMap() async {
    if (_locatingCurrentLocation) {
      return;
    }

    setState(() => _locatingCurrentLocation = true);

    try {
      final position = await _getCurrentLocation();

      if (position == null || !mounted) {
        return;
      }

      setState(() {
        _gpsAccuracyMeters = position.accuracy;
        _pendingCurrentLocation = {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
        };
      });

      _pushCurrentLocationToMap();
    } catch (_) {
      if (!mounted) return;
      _showSnack('Gagal mengambil lokasi saat ini.');
    } finally {
      if (mounted) {
        setState(() => _locatingCurrentLocation = false);
      }
    }
  }

  void _showQuestBottomSheet(Quest quest) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return QuestDetailSheet(
          quest: quest,
          onNavigate: () => _navigateToQuest(quest),
          onStart: () => _startQuest(quest),
        );
      },
    );
  }

  Future<void> _navigateToQuest(Quest quest) async {
    Navigator.pop(context);
    
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${quest.latitude},${quest.longitude}';
    
    if (await canLaunchUrl(Uri.parse(mapsUrl))) {
      await launchUrl(Uri.parse(mapsUrl), mode: LaunchMode.externalApplication);
    } else {
      _showSnack('Tidak bisa membuka Google Maps');
    }
  }

  Future<void> _startQuizQuest(Quest quest) async {
    Navigator.pop(context);
    
    if (!quest.isUnlocked) {
      _showSnack('Quest belum unlock. Bergerak lebih dekat!');
      return;
    }

    // Show loading
    _showSnack('Memuat soal...');

    try {
      final questions = await ApiClient.getQuizQuestions(quest.id);

      if (!mounted) return;

      if (questions.isEmpty) {
        _showSnack('Tidak ada soal untuk quest ini.');
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizQuestScreen(
            quest: quest,
            questions: questions,
            onComplete: () {
              Navigator.pop(context);
              _showSnack('Quest ${quest.title} berhasil diselesaikan!');
            },
          ),
        ),
      );
    } catch (error) {
      _showSnack('Gagal memuat soal: $error');
    }
  }

  void _startQuest(Quest quest) {
    if (quest.isUnlocked) {
      if (quest.type == 'Quiz' || quest.type == 'Puzzle') {
        _startQuizQuest(quest);
      } else if (quest.type == 'GPS') {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GpsQuestScreen(
              quest: quest,
              onComplete: () {
                Navigator.pop(context);
                _showSnack('Quest ${quest.title} berhasil diselesaikan!');
              },
            ),
          ),
        );
      } else if (quest.type == 'AR') {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArQuestScreen(
              quest: quest,
              onComplete: () {
                Navigator.pop(context);
                _showSnack('Quest ${quest.title} berhasil diselesaikan!');
              },
            ),
          ),
        );
      } else if (quest.type == 'Treasure Hunt') {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TreasureHuntQuestScreen(
              quest: quest,
              onComplete: () {
                Navigator.pop(context);
                _showSnack('Quest ${quest.title} berhasil diselesaikan!');
              },
            ),
          ),
        );
      } else if (quest.type == 'Plant ID') {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlantIdQuestScreen(
              quest: quest,
              onComplete: () {
                Navigator.pop(context);
                _showSnack('Quest ${quest.title} berhasil diselesaikan!');
              },
            ),
          ),
        );
      } else {
        _showSnack('Quest type ${quest.type} belum didukung.');
      }
    } else {
      Navigator.pop(context);
      _showSnack('Quest belum unlock. Bergerak lebih dekat!');
    }
  }

  Future<void> _showFilterSheet() async {
    final selected = Set<String>.from(_selectedTypes);
    var status = _statusFilter;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                20 + MediaQuery.of(context).viewPadding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Quest',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _questTypes.map((type) {
                      final active = selected.contains(type);

                      return FilterChip(
                        selected: active,
                        label: Text(type),
                        onSelected: (value) {
                          setModalState(() {
                            if (value) {
                              selected.add(type);
                            } else {
                              selected.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua')),
                      DropdownMenuItem(
                        value: 'incomplete',
                        child: Text('Belum selesai'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Selesai'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => status = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _selectedTypes
                          ..clear()
                          ..addAll(selected);
                        _statusFilter = status;
                        _applyFilters();
                      });
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.deepGreen,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Terapkan Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    await ApiClient.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TutorialOverlay(
        showTutorial: _showMapTutorial && _tabIndex == 0,
        onComplete: () {
          setState(() => _showMapTutorial = false);
        },
        child: IndexedStack(
          index: _tabIndex,
          children: [
            _buildMapTab(),
            const LeaderboardScreen(),
            const VoucherScreen(),
            _ProfileTab(onLogout: _logout),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Voucher',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showFilterSheet,
              backgroundColor: AppPalette.deepGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.filter_alt_outlined),
              label: const Text('Filter'),
            )
          : null,
    );
  }

  Widget _buildMapTab() {
    return Stack(
      children: [
        Positioned.fill(
          child: _webViewController == null
              ? const Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: _webViewController!),
        ),
        Positioned(
          top: 48,
          left: 14,
          child: FloatingActionButton(
            heroTag: 'mapSettings',
            mini: true,
            backgroundColor: Colors.black.withOpacity(0.65),
            foregroundColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            child: const Icon(Icons.settings_outlined, size: 20),
          ),
        ),
        Positioned(
          top: 48,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _gpsAccuracyMeters == null
                  ? 'GPS: --'
                  : 'GPS +/- ${_gpsAccuracyMeters!.round()}m',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (_loading)
          const Positioned(
            top: 94,
            right: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        Positioned(
          left: 14,
          right: 14,
          top: 48,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.93),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Quest Map Visitor',
              style: TextStyle(
                color: AppPalette.darkGreen,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Positioned(
          left: 14,
          bottom: 114,
          child: FloatingActionButton(
            heroTag: 'mobileCurrentLocation',
            backgroundColor: Colors.white,
            foregroundColor: AppPalette.deepGreen,
            onPressed: _locatingCurrentLocation ? null : _showCurrentLocationOnMap,
            child: _locatingCurrentLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  static const List<String> _questTypes = [
    'AR',
    'GPS',
    'Quiz',
    'Plant ID',
    'Treasure Hunt',
    'Puzzle',
  ];
}
