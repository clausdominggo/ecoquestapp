<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="csrf-token" content="{{ csrf_token() }}" />
  <title>Quest Management - EcoQuest</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    :root {
      --bg: #f2f6f3;
      --side: #103629;
      --sideText: #d6efe5;
      --primary: #0e7a5a;
      --card: #fff;
      --muted: #708178;
      --danger: #c0392b;
      --border: #dce7e1;
    }
    * { box-sizing: border-box; }
    body { margin:0; font-family: Segoe UI, Arial, sans-serif; background:var(--bg); color:#1f2e28; }
    .layout { display:flex; min-height:100vh; }
    .sidebar { width:260px; background:var(--side); color:var(--sideText); padding:22px 18px; position:sticky; top:0; height:100vh; }
    .logo { font-weight:800; font-size:24px; margin-bottom:24px; }
    .nav a { display:block; color:var(--sideText); text-decoration:none; padding:11px 12px; border-radius:10px; margin-bottom:8px; }
    .nav a.active, .nav a:hover { background: rgba(255,255,255,.12); }
    .content { flex:1; padding:20px; }
    .top { display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; gap:12px; flex-wrap:wrap; }
    .card { background:var(--card); border-radius:16px; padding:16px; box-shadow:0 5px 14px rgba(12,23,18,.06); margin-bottom:12px; }
    .card h3 { margin-top:0; }
    .grid { display:grid; grid-template-columns:repeat(2, minmax(0, 1fr)); gap:12px; }
    .wide { grid-column:1 / -1; }
    label { font-size:12px; color:#58665f; display:block; margin-bottom:5px; font-weight:600; }
    input, select, textarea { width:100%; border:1px solid var(--border); border-radius:10px; padding:10px; box-sizing:border-box; background:#fff; }
    textarea { min-height:75px; }
    button, .btn { border:none; background:var(--primary); color:#fff; border-radius:10px; padding:11px 15px; font-weight:700; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; justify-content:center; gap:8px; }
    .btn-secondary { background:#e9f3ee; color:#0c5f46; }
    .btn-danger { background:var(--danger); }
    .btn-row { display:flex; gap:10px; flex-wrap:wrap; }
    #map { height:320px; border-radius:10px; }
    .leaflet-control.locate-control { border:none; box-shadow:0 6px 18px rgba(16,54,41,.22); border-radius:999px; overflow:hidden; }
    .leaflet-control.locate-control a { display:flex; align-items:center; justify-content:center; width:36px; height:36px; background:#fff; color:#103629; text-decoration:none; font-size:22px; line-height:1; font-weight:700; }
    .leaflet-control.locate-control a:hover { background:#edf4f0; }
    table { width:100%; border-collapse:collapse; }
    th, td { border-bottom:1px solid #edf1ee; padding:10px 8px; text-align:left; font-size:12px; vertical-align:top; }
    th { color:#5e6c65; text-transform:uppercase; letter-spacing:.03em; font-size:11px; }
    .muted { color:var(--muted); }
    .pill { display:inline-flex; align-items:center; padding:4px 8px; border-radius:999px; background:#edf7f2; color:#0c5f46; font-size:11px; font-weight:700; }
    .empty-state { padding:18px; text-align:center; color:var(--muted); }
    .section-head { display:flex; justify-content:space-between; align-items:center; gap:12px; flex-wrap:wrap; margin-bottom:10px; }
    .table-wrap { overflow:auto; }
    @media (max-width: 1100px) {
      .sidebar { width:220px; }
    }
    @media (max-width: 820px) {
      .layout { flex-direction:column; }
      .sidebar { width:100%; height:auto; position:relative; }
      .grid { grid-template-columns:1fr; }
    }
  </style>
</head>
<body>
<div class="layout">
  <aside class="sidebar">
    <div class="logo">EcoQuest Admin</div>
    <nav class="nav">
      <a href="/admin/dashboard">Dashboard</a>
      <a href="/admin/quests" class="active">Quest Points</a>
    </nav>
    <form class="logout-form" method="post" action="/admin/logout">
      @csrf
      <button type="submit">Logout</button>
    </form>
  </aside>

  <main class="content">
    <div class="top">
      <div>
        <h2 style="margin:0;">Quest Management</h2>
        <div class="muted">CRUD lengkap untuk quest yang tampil di dashboard dan aplikasi visitor.</div>
      </div>
      <a class="btn btn-secondary" href="/admin/dashboard">Kembali ke Dashboard</a>
    </div>

    @if(session('success'))
      <div class="card" style="border-left:4px solid var(--primary); color:#0c5f46; font-weight:700;">{{ session('success') }}</div>
    @endif

    @if($errors->any())
      <div class="card" style="border-left:4px solid var(--danger); color:var(--danger);">
        <div style="font-weight:800; margin-bottom:8px;">Periksa input berikut:</div>
        <ul style="margin:0; padding-left:18px;">
          @foreach($errors->all() as $error)
            <li>{{ $error }}</li>
          @endforeach
        </ul>
      </div>
    @endif

    <div class="card">
      <div class="section-head">
        <div>
          <h3 style="margin-bottom:4px;">Form Quest</h3>
          <div class="muted">Klik peta untuk mengisi latitude/longitude dengan cepat.</div>
        </div>
        @if($editingQuest)
          <span class="pill">Edit mode: #{{ $editingQuest->id }}</span>
        @endif
      </div>

      <div id="map"></div>

      <form method="post" action="{{ $editingQuest ? url('/admin/quests/'.$editingQuest->id) : url('/admin/quests') }}" style="margin-top:16px;">
        @csrf
        @if($editingQuest)
          @method('PUT')
        @endif

        <div class="grid">
          <div>
            <label>Title</label>
            <input name="title" value="{{ old('title', $editingQuest->title ?? '') }}" required>
          </div>
          <div>
            <label>Type</label>
            <select name="type">
              @foreach(['AR','GPS','Quiz','Plant ID','Treasure Hunt','Puzzle'] as $type)
                <option value="{{ $type }}" @selected(old('type', $editingQuest->type ?? 'AR') === $type)>{{ $type }}</option>
              @endforeach
            </select>
          </div>
          <div>
            <label>Mode</label>
            <select name="mode">
              @foreach(['gps','quiz','puzzle'] as $mode)
                <option value="{{ $mode }}" @selected(old('mode', $editingQuest->mode ?? 'gps') === $mode)>{{ $mode }}</option>
              @endforeach
            </select>
          </div>
          <div>
            <label>Points</label>
            <input type="number" name="points" value="{{ old('points', $editingQuest->points ?? 30) }}" required>
          </div>
          <div>
            <label>Latitude</label>
            <input id="lat" name="latitude" value="{{ old('latitude', $editingQuest->latitude ?? '') }}" required>
          </div>
          <div>
            <label>Longitude</label>
            <input id="lng" name="longitude" value="{{ old('longitude', $editingQuest->longitude ?? '') }}" required>
          </div>
          <div>
            <label>Unlock Radius (m)</label>
            <input type="number" step="0.1" name="unlock_radius_m" value="{{ old('unlock_radius_m', $editingQuest->unlock_radius_m ?? 20) }}" required>
          </div>
          <div>
            <label>Accuracy Threshold (m)</label>
            <input type="number" step="0.1" name="accuracy_threshold_m" value="{{ old('accuracy_threshold_m', $editingQuest->accuracy_threshold_m ?? 12) }}" required>
          </div>
          <div>
            <label>QR Code Trigger</label>
            <input name="qr_code" value="{{ old('qr_code', $editingQuest->qr_code ?? '') }}" placeholder="mis: PUZZLE-GATE-01">
          </div>
          <div>
            <label>Timer Seconds</label>
            <input type="number" name="timer_seconds" value="{{ old('timer_seconds', $editingQuest->timer_seconds ?? 60) }}">
          </div>
          <div class="wide">
            <label>Instruction</label>
            <textarea name="instruction" placeholder="Instruksi quest">{{ old('instruction', $editingQuest->instruction ?? '') }}</textarea>
          </div>
          <div class="wide">
            <label>Quiz Question</label>
            <textarea name="quiz_question" placeholder="Pertanyaan untuk quest quiz">{{ old('quiz_question', $editingQuest->quiz_question ?? '') }}</textarea>
          </div>
          <div class="wide">
            <label>Quiz Options (pisahkan dengan |)</label>
            <input name="quiz_options" value="{{ old('quiz_options', isset($editingQuest) && is_array($editingQuest->quiz_options) ? implode('|', $editingQuest->quiz_options) : ($editingQuest->quiz_options ?? '')) }}" placeholder="A|B|C|D">
          </div>
          <div>
            <label>Quiz Answer</label>
            <input name="quiz_answer" value="{{ old('quiz_answer', $editingQuest->quiz_answer ?? '') }}" placeholder="jawaban tepat">
          </div>
          <div>
            <label>Active</label>
            <select name="is_active">
              <option value="1" @selected(old('is_active', $editingQuest->is_active ?? true))>Aktif</option>
              <option value="0" @selected(!old('is_active', $editingQuest->is_active ?? true))>Nonaktif</option>
            </select>
          </div>
        </div>

        <div class="btn-row" style="margin-top:16px;">
          <button type="submit">{{ $editingQuest ? 'Update Quest' : 'Simpan Quest' }}</button>
          @if($editingQuest)
            <a class="btn btn-secondary" href="/admin/quests">Batal Edit</a>
          @endif
        </div>
      </form>
    </div>

    <div class="card">
      <div class="section-head">
        <div>
          <h3 style="margin-bottom:4px;">Daftar Quest</h3>
          <div class="muted">Edit, hapus, atau lihat data quest yang sudah tersimpan.</div>
        </div>
        <span class="pill">Total: {{ $quests->count() }}</span>
      </div>

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Title</th>
              <th>Type</th>
              <th>Mode</th>
              <th>Lat</th>
              <th>Lng</th>
              <th>Points</th>
              <th>Status</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            @forelse($quests as $quest)
              <tr>
                <td>
                  <div style="font-weight:700;">{{ $quest->title }}</div>
                  <div class="muted">Radius {{ $quest->unlock_radius_m }}m | Akurasi {{ $quest->accuracy_threshold_m }}m</div>
                </td>
                <td>{{ $quest->type }}</td>
                <td>{{ $quest->mode }}</td>
                <td>{{ $quest->latitude }}</td>
                <td>{{ $quest->longitude }}</td>
                <td>{{ $quest->points }}</td>
                <td>
                  <span class="pill" style="background:{{ $quest->is_active ? '#edf7f2' : '#f8efef' }}; color:{{ $quest->is_active ? '#0c5f46' : '#a33a2b' }};">
                    {{ $quest->is_active ? 'Aktif' : 'Nonaktif' }}
                  </span>
                </td>
                <td>
                  <div class="btn-row">
                    <a class="btn btn-secondary" href="{{ url('/admin/quests?edit='.$quest->id) }}">Edit</a>
                    <form method="post" action="{{ url('/admin/quests/'.$quest->id) }}" onsubmit="return confirm('Hapus quest ini?')">
                      @csrf
                      @method('DELETE')
                      <button type="submit" class="btn btn-danger">Hapus</button>
                    </form>
                  </div>
                </td>
              </tr>
            @empty
              <tr>
                <td colspan="8">
                  <div class="empty-state">Belum ada quest. Silakan buat quest pertama dari form di atas.</div>
                </td>
              </tr>
            @endforelse
          </tbody>
        </table>
      </div>
    </div>
  </main>
</div>

<script>
  const map = L.map('map').setView([-6.5985, 106.799], 16);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 20, attribution: '&copy; OpenStreetMap contributors' }).addTo(map);
  let marker = null;

  const existingLat = document.getElementById('lat').value;
  const existingLng = document.getElementById('lng').value;
  if (existingLat && existingLng) {
    const lat = Number(existingLat);
    const lng = Number(existingLng);
    if (!Number.isNaN(lat) && !Number.isNaN(lng)) {
      marker = L.marker([lat, lng]).addTo(map);
      map.setView([lat, lng], 18);
    }
  }

  const LocateControl = L.Control.extend({
    options: { position: 'topright' },
    onAdd() {
      const container = L.DomUtil.create('div', 'leaflet-control locate-control');
      const button = L.DomUtil.create('a', '', container);
      button.href = '#';
      button.title = 'Tampilkan lokasi anda saat ini';
      button.setAttribute('aria-label', 'Tampilkan lokasi anda saat ini');
      button.innerHTML = '+';
      L.DomEvent.disableClickPropagation(container);
      L.DomEvent.disableScrollPropagation(container);
      L.DomEvent.on(button, 'click', (event) => {
        L.DomEvent.preventDefault(event);
        focusCurrentLocation();
      });
      return container;
    },
  });

  map.addControl(new LocateControl());

  function setMarker(lat, lng) {
    if (marker) map.removeLayer(marker);
    marker = L.marker([lat, lng]).addTo(map);
    map.setView([lat, lng], 18);
  }

  function focusCurrentLocation() {
    if (!navigator.geolocation) {
      alert('Browser tidak mendukung GPS.');
      return;
    }

    navigator.geolocation.getCurrentPosition((position) => {
      const { latitude, longitude } = position.coords;
      const lat = latitude.toFixed(7);
      const lng = longitude.toFixed(7);

      document.getElementById('lat').value = lat;
      document.getElementById('lng').value = lng;
      setMarker(latitude, longitude);
      marker.bindPopup(`Lokasi Anda Saat Ini<br/>${lat}, ${lng}`).openPopup();
    }, (error) => {
      alert(error?.message ?? 'GPS tidak tersedia.');
    }, {
      enableHighAccuracy: true,
      timeout: 15000,
      maximumAge: 0,
    });
  }

  map.on('click', (event) => {
    const { lat, lng } = event.latlng;
    document.getElementById('lat').value = lat.toFixed(7);
    document.getElementById('lng').value = lng.toFixed(7);
    setMarker(lat, lng);
  });
</script>
</body>
</html>
