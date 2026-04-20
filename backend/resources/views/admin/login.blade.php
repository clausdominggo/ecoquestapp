<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Login - EcoQuest</title>
  <style>
    body { margin: 0; font-family: Segoe UI, Arial, sans-serif; background: linear-gradient(160deg, #0f3d2f, #1f7c5c); min-height: 100vh; display: grid; place-items: center; }
    .card { width: min(440px, 92vw); background: #ffffff; border-radius: 20px; padding: 28px; box-shadow: 0 20px 40px rgba(0,0,0,.2); }
    h1 { margin: 0 0 8px; color: #0e7a5a; }
    p { margin: 0 0 20px; color: #6f7a74; }
    label { display: block; font-size: 13px; margin-bottom: 6px; color: #395047; }
    input { width: 100%; border: 1px solid #d6e2db; border-radius: 12px; padding: 12px; margin-bottom: 14px; font-size: 14px; box-sizing: border-box; }
    button { width: 100%; border: none; border-radius: 12px; padding: 13px; background: #0e7a5a; color: #fff; font-weight: 700; cursor: pointer; }
    .error { margin-bottom: 12px; background: #ffefef; color: #b62e2e; border-radius: 10px; padding: 10px; font-size: 13px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Admin Login</h1>
    <p>Masuk ke dashboard admin EcoQuest.</p>

    @if($errors->any())
      <div class="error">{{ $errors->first() }}</div>
    @endif

    <form method="post" action="/admin/login">
      @csrf
      <label>Email</label>
      <input type="email" name="email" value="{{ old('email') }}" required>

      <label>Password</label>
      <input type="password" name="password" required>

      <button type="submit">LOGIN ADMIN</button>
    </form>
  </div>
</body>
</html>
