<?php

namespace App\Http\Middleware;

use App\Models\User;
use App\Support\JwtService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdminSession
{
    public function __construct(private readonly JwtService $jwtService)
    {
    }

    public function handle(Request $request, Closure $next): Response
    {
        $token = (string) $request->session()->get('admin_jwt', '');

        if ($token === '') {
            return redirect('/admin/login');
        }

        try {
            $payload = $this->jwtService->decode($token);
        } catch (\Throwable) {
            $request->session()->forget('admin_jwt');

            return redirect('/admin/login');
        }

        if (($payload['role'] ?? null) !== 'admin') {
            $request->session()->forget('admin_jwt');

            return redirect('/admin/login')->withErrors([
                'email' => 'Akses admin ditolak.',
            ]);
        }

        $user = User::query()->find((int) ($payload['sub'] ?? 0));

        if (!$user || $user->role !== 'admin') {
            $request->session()->forget('admin_jwt');

            return redirect('/admin/login');
        }

        $request->setUserResolver(static fn (): User => $user);

        return $next($request);
    }
}
