<?php

namespace App\Http\Controllers\Web\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\JwtService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\View\View;

class AuthController extends Controller
{
    public function __construct(private readonly JwtService $jwtService)
    {
    }

    public function showLogin(): View|RedirectResponse
    {
        if (session()->has('admin_jwt')) {
            return redirect('/admin/dashboard');
        }

        return view('admin.login');
    }

    public function login(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::query()->where('email', $validated['email'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return back()->withErrors([
                'email' => 'Email atau password tidak valid.',
            ])->onlyInput('email');
        }

        if ($user->role !== 'admin') {
            return back()->withErrors([
                'email' => 'Role Anda bukan admin.',
            ])->onlyInput('email');
        }

        $token = $this->jwtService->createAccessToken($user->id, $user->email, $user->role);

        $request->session()->put('admin_jwt', $token);

        return redirect('/admin/dashboard');
    }

    public function logout(Request $request): RedirectResponse
    {
        $request->session()->forget('admin_jwt');

        return redirect('/admin/login');
    }
}
