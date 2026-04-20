<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Admin Dashboard - EcoQuest</title>
  <meta name="csrf-token" content="{{ csrf_token() }}" />
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.css" />
  <link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.Default.css" />
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <script src="https://unpkg.com/leaflet.markercluster@1.5.3/dist/leaflet.markercluster.js"></script>
  <style>
    :root { --bg:#f2f6f3; --side:#103629; --sideText:#d6efe5; --primary:#0e7a5a; --card:#fff; --muted:#708178; }
    * { box-sizing: border-box; }
    body { margin:0; font-family: Segoe UI, Arial, sans-serif; background:var(--bg); color:#1f2e28; }
    .layout { display:flex; min-height:100vh; }
    .sidebar { width:260px; background:var(--side); color:var(--sideText); padding:22px 18px; position: sticky; top:0; height:100vh; }
    .logo { font-weight:800; font-size:24px; margin-bottom:24px; }
    .nav a { display:block; color:var(--sideText); text-decoration:none; padding:11px 12px; border-radius:10px; margin-bottom:8px; }
    .nav a.active, .nav a:hover { background: rgba(255,255,255,.12); }
    .content { flex:1; padding:20px; }
    .top { display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; }
    .metrics { display:grid; grid-template-columns:repeat(4, minmax(170px,1fr)); gap:12px; }
    .card { background:var(--card); border-radius:16px; padding:14px; box-shadow:0 5px 14px rgba(12,23,18,.06); }
    .metric-title { color:var(--muted); font-size:12px; }
    .metric-value { font-size:28px; font-weight:800; color:#0c5f46; margin-top:4px; }
    .main-grid { display:grid; grid-template-columns:2fr 1fr; gap:12px; margin-top:12px; }
    #activityMap { height:370px; border-radius:14px; overflow:hidden; }
    .chart-wrap { height:190px; }
    .leaderboard { margin-top:12px; }
    table { width:100%; border-collapse: collapse; }
    th, td { text-align:left; padding:10px 8px; border-bottom:1px solid #e8efea; font-size:13px; }
    th { color:#5e6c65; font-weight:700; font-size:12px; }
    .export-btn, .logout-btn { border:none; background:var(--primary); color:#fff; border-radius:10px; padding:10px 14px; font-weight:700; text-decoration:none; cursor:pointer; }
    .logout-form { margin-top: 18px; }
    .map-note { color: var(--muted); font-size: 13px; margin: 8px 0 0; }
    .status-grid { display:grid; grid-template-columns:repeat(3, minmax(0,1fr)); gap:12px; margin-top:12px; }
    .status-line { font-size:13px; color:#3e524a; margin-top:8px; line-height:1.5; }
    .legend { display:flex; gap:12px; flex-wrap:wrap; margin-top:10px; font-size:12px; color:#4f635c; }
    .legend span { display:inline-flex; align-items:center; gap:6px; }
    .swatch { width:10px; height:10px; border-radius:999px; display:inline-block; }
    .leaflet-control.locate-control {
      border: none;
      box-shadow: 0 6px 18px rgba(16, 54, 41, 0.22);
      border-radius: 999px;
      overflow: hidden;
    }
    .leaflet-control.locate-control a {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 36px;
      height: 36px;
      background: #fff;
      color: #103629;
      text-decoration: none;
      font-size: 22px;
      line-height: 1;
      font-weight: 700;
    }
    .leaflet-control.locate-control a:hover {
      background: #edf4f0;
    }
    @media (max-width: 1100px) {
      .metrics, .status-grid { grid-template-columns:repeat(2,minmax(0,1fr)); }
      .main-grid { grid-template-columns:1fr; }
      .sidebar { width:220px; }
    }
    @media (max-width: 720px) {
      .metrics, .status-grid { grid-template-columns:1fr; }
      .top { flex-direction:column; align-items:flex-start; gap:10px; }
    }
  </style>
</head>
<body>
<div class="layout">
  <aside class="sidebar">
    <div class="logo">EcoQuest Admin</div>
    <nav class="nav">
      <a href="/admin/dashboard" class="active">Dashboard</a>
      <a href="/admin/quests">Quest Points</a>
    </nav>
    <form class="logout-form" method="post" action="/admin/logout">
      @csrf
      <button class="logout-btn" type="submit">Logout</button>
    </form>
  </aside>

  <main class="content">
    <div class="top">
      <h2>Main Dashboard</h2>
      <a class="export-btn" href="/admin/api/leaderboard/export">Export CSV</a>
    </div>

    <section class="metrics">
      <article class="card"><div class="metric-title">Total Registrations</div><div class="metric-value" id="metricRegistrations">0</div></article>
      <article class="card"><div class="metric-title">Total Active Participants</div><div class="metric-value" id="metricActive">0</div></article>
      <article class="card"><div class="metric-title">Total Active Admins</div><div class="metric-value" id="metricAdmins">0</div></article>
      <article class="card"><div class="metric-title">Quests Completed Today</div><div class="metric-value" id="metricCompleted">0</div></article>
      <article class="card"><div class="metric-title">Vouchers Redeemed</div><div class="metric-value" id="metricVouchers">0</div></article>
    </section>

    <section class="status-grid">
      <article class="card">
        <div class="metric-title">Lokasi Admin Saat Ini</div>
        <div class="status-line" id="adminLocationStatus">Menunggu izin GPS browser.</div>
      </article>
      <article class="card">
        <div class="metric-title">Akurasi Admin</div>
        <div class="status-line" id="adminAccuracyStatus">-</div>
      </article>
      <article class="card">
        <div class="metric-title">Quest Aktif Dipantau</div>
        <div class="status-line" id="questMonitorStatus">0 quest aktif terdaftar.</div>
      </article>
    </section>

    <section class="main-grid">
      <article class="card">
        <h3>Live Activity Map</h3>
        <p class="map-note">Peta ini menampilkan visitor, admin, dan titik quest aktif secara live.</p>
        <div id="activityMap"></div>
        <div class="legend">
          <span><i class="swatch" style="background:#2f80ed"></i>Visitor</span>
          <span><i class="swatch" style="background:#f2994a"></i>Admin</span>
          <span><i class="swatch" style="background:#27ae60"></i>Quest</span>
        </div>
      </article>

      <article class="card">
        <h3>Tier Distribution</h3>
        <div class="chart-wrap"><canvas id="tierChart"></canvas></div>
        <h3>Quest Completions (7 hari)</h3>
        <div class="chart-wrap"><canvas id="completionChart"></canvas></div>
      </article>
    </section>

    <section class="leaderboard card">
      <h3>Live Leaderboard</h3>
      <table>
        <thead>
          <tr><th>Rank</th><th>Nama</th><th>Tier</th><th>Poin</th><th>Quest</th><th>Last Activity</th></tr>
        </thead>
        <tbody id="leaderboardBody"></tbody>
      </table>
    </section>
  </main>
</div>

<script>
  const map = L.map('activityMap').setView([-6.5985, 106.799], 15);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 20,
    attribution: '&copy; OpenStreetMap contributors',
  }).addTo(map);
  const cluster = L.markerClusterGroup();
  map.addLayer(cluster);
  const questLayer = L.layerGroup().addTo(map);
  const adminLayer = L.layerGroup().addTo(map);
  const currentLocationLayer = L.layerGroup().addTo(map);
  let adminWatchId = null;
  let mapHasBeenCentered = false;

  function createMarker(color, label) {
    return L.divIcon({
      className: '',
      html: `<div style="width:16px;height:16px;border-radius:999px;background:${color};border:3px solid #fff;box-shadow:0 4px 12px rgba(0,0,0,.25);"></div>`,
      iconSize: [16, 16],
      iconAnchor: [8, 8],
      popupAnchor: [0, -8],
      tooltipAnchor: [0, -8],
      ariaLabel: label,
    });
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
        centerMapOnCurrentLocation();
      });
      return container;
    },
  });

  map.addControl(new LocateControl());

  function centerMapOnCurrentLocation() {
    if (!navigator.geolocation) {
      document.getElementById('adminLocationStatus').textContent = 'Browser tidak mendukung GPS.';
      return;
    }

    navigator.geolocation.getCurrentPosition((position) => {
      const { latitude, longitude, accuracy } = position.coords;
      const latlng = [latitude, longitude];

      currentLocationLayer.clearLayers();
      const marker = L.marker(latlng, { icon: createMarker('#103629', 'Lokasi Anda') });
      marker.bindPopup(`<b>Lokasi Anda Saat Ini</b><br/>Akurasi: ${Math.round(accuracy)} meter`);
      currentLocationLayer.addLayer(marker);
      map.setView(latlng, 18);
      marker.openPopup();

      document.getElementById('adminLocationStatus').textContent = `${latitude.toFixed(6)}, ${longitude.toFixed(6)}`;
      document.getElementById('adminAccuracyStatus').textContent = `${Math.round(accuracy)} meter`;
    }, (error) => {
      const message = error?.message ?? 'GPS tidak tersedia.';
      document.getElementById('adminLocationStatus').textContent = message;
    }, {
      enableHighAccuracy: true,
      timeout: 15000,
      maximumAge: 0,
    });
  }

  const tierChart = new Chart(document.getElementById('tierChart'), {
    type: 'doughnut',
    data: { labels: [], datasets: [{ data: [], backgroundColor: ['#5c6bc0','#66bb6a','#ffa726','#ef5350'] }] },
    options: { responsive: true, maintainAspectRatio: false }
  });

  const completionChart = new Chart(document.getElementById('completionChart'), {
    type: 'line',
    data: { labels: [], datasets: [{ label: 'Completions', data: [], borderColor: '#0e7a5a', backgroundColor: 'rgba(14,122,90,.15)', fill: true, tension: .35 }] },
    options: { responsive: true, maintainAspectRatio: false }
  });

  async function getJson(url) {
    const response = await fetch(url);
    if (!response.ok) return null;
    return await response.json();
  }

  function csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content ?? '';
  }

  async function postJson(url, payload) {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
        'Accept': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      return null;
    }

    return await response.json();
  }

  async function refreshMetrics() {
    const data = await getJson('/admin/api/metrics');
    if (!data) return;
    document.getElementById('metricRegistrations').textContent = data.total_registrations;
    document.getElementById('metricActive').textContent = data.total_active_participants;
    document.getElementById('metricAdmins').textContent = data.total_active_admins ?? 0;
    document.getElementById('metricCompleted').textContent = data.total_quests_completed_today;
    document.getElementById('metricVouchers').textContent = data.total_vouchers_redeemed;
  }

  async function refreshMap({ centerMap = false } = {}) {
    const response = await getJson('/admin/api/active-map');
    if (!response) return;
    cluster.clearLayers();
    questLayer.clearLayers();
    adminLayer.clearLayers();
    const bounds = [];

    (response.participants || []).forEach((point) => {
      const marker = L.marker([point.latitude, point.longitude], { icon: createMarker('#2f80ed', point.name) });
      marker.bindPopup(`<b>${point.name}</b><br/>Role: Visitor<br/>Akurasi: ${point.accuracy ?? '-'}m<br/>${point.recorded_at}`);
      cluster.addLayer(marker);
      bounds.push([point.latitude, point.longitude]);
    });

    (response.admins || []).forEach((point) => {
      const marker = L.marker([point.latitude, point.longitude], { icon: createMarker('#f2994a', point.name) });
      marker.bindPopup(`<b>${point.name}</b><br/>Role: Admin<br/>Akurasi: ${point.accuracy ?? '-'}m<br/>${point.recorded_at}`);
      adminLayer.addLayer(marker);
      bounds.push([point.latitude, point.longitude]);
    });

    (response.quests || []).forEach((quest) => {
      const marker = L.marker([quest.latitude, quest.longitude], { icon: createMarker('#27ae60', quest.title) });
      marker.bindPopup(`<b>${quest.title}</b><br/>${quest.type} / ${quest.mode}<br/>Poin: ${quest.points}<br/>Status: ${quest.status}<br/>Radius: ${quest.unlock_radius_m}m`);
      questLayer.addLayer(marker);
      bounds.push([quest.latitude, quest.longitude]);
    });

    document.getElementById('questMonitorStatus').textContent = `${(response.quests || []).length} quest aktif terdaftar.`;

    if (bounds.length > 0 && (centerMap || !mapHasBeenCentered)) {
      map.fitBounds(bounds, { padding: [20,20] });
      mapHasBeenCentered = true;
    }
  }

  async function refreshTierChart() {
    const response = await getJson('/admin/api/tier-distribution');
    if (!response) return;
    tierChart.data.labels = (response.data || []).map((row) => row.tier);
    tierChart.data.datasets[0].data = (response.data || []).map((row) => row.total);
    tierChart.update();
  }

  async function refreshCompletionChart() {
    const response = await getJson('/admin/api/quest-completions');
    if (!response) return;
    completionChart.data.labels = (response.data || []).map((row) => row.date);
    completionChart.data.datasets[0].data = (response.data || []).map((row) => row.total);
    completionChart.update();
  }

  async function refreshLeaderboard() {
    const response = await getJson('/admin/api/leaderboard');
    if (!response) return;
    const body = document.getElementById('leaderboardBody');
    body.innerHTML = '';

    (response.data || []).forEach((row, index) => {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${index + 1}</td><td>${row.name}</td><td>${row.tier}</td><td>${row.points}</td><td>${row.quests_completed}</td><td>${row.last_activity_at ?? '-'}</td>`;
      body.appendChild(tr);
    });
  }

  async function refreshAll() {
    await Promise.all([
      refreshMetrics(),
      refreshMap(),
      refreshTierChart(),
      refreshCompletionChart(),
      refreshLeaderboard(),
    ]);
  }

  function startAdminLocationTracking() {
    if (!navigator.geolocation) {
      document.getElementById('adminLocationStatus').textContent = 'Browser tidak mendukung GPS.';
      return;
    }

    adminWatchId = navigator.geolocation.watchPosition(async (position) => {
      const { latitude, longitude, accuracy, speed } = position.coords;
      document.getElementById('adminLocationStatus').textContent = `${latitude.toFixed(6)}, ${longitude.toFixed(6)}`;
      document.getElementById('adminAccuracyStatus').textContent = `${Math.round(accuracy)} meter`;

      await postJson('/admin/api/location', {
        latitude,
        longitude,
        accuracy,
        speed,
        is_active: true,
      });
    }, (error) => {
      const message = error?.message ?? 'GPS tidak tersedia.';
      document.getElementById('adminLocationStatus').textContent = message;
      document.getElementById('adminAccuracyStatus').textContent = '-';
    }, {
      enableHighAccuracy: true,
      maximumAge: 3000,
      timeout: 15000,
    });
  }

  refreshAll();
  startAdminLocationTracking();
  setInterval(() => {
    refreshMetrics();
    refreshTierChart();
    refreshCompletionChart();
    refreshLeaderboard();
    refreshMap();
  }, 30000);
</script>
</body>
</html>
