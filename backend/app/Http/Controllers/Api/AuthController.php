<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QuestAttempt;
use App\Models\RefreshToken;
use App\Models\User;
use App\Models\UserProgress;
use App\Models\Voucher;
use App\Support\JwtService;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function __construct(private readonly JwtService $jwtService)
    {
    }

    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'max:30'],
            'password' => ['required', 'string', 'min:8'],
            'device_name' => ['nullable', 'string', 'max:100'],
            'platform' => ['nullable', 'string', 'max:20'],
        ]);

        $platform = strtolower((string) ($validated['platform'] ?? 'mobile'));

        if ($platform !== 'mobile') {
            return response()->json([
                'message' => 'Endpoint ini hanya untuk aplikasi mobile visitor.',
            ], 403);
        }

        $user = User::query()->create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'],
            'role' => 'visitor',
            'password' => $validated['password'],
        ]);

        return response()->json($this->issueTokens($user, $validated['device_name'] ?? null), 201);
    }

    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:100'],
            'platform' => ['nullable', 'string', 'max:20'],
        ]);

        $platform = strtolower((string) ($validated['platform'] ?? 'mobile'));

        if ($platform !== 'mobile') {
            return response()->json([
                'message' => 'Endpoint ini hanya untuk aplikasi mobile visitor.',
            ], 403);
        }

        $user = User::query()->where('email', $validated['email'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'message' => 'Email atau password tidak valid.',
            ], 401);
        }

        if ($user->role !== 'visitor') {
            return response()->json([
                'message' => 'Hanya akun visitor yang boleh login di aplikasi mobile.',
            ], 403);
        }

        return response()->json($this->issueTokens($user, $validated['device_name'] ?? null));
    }

    public function refresh(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'refresh_token' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ]);

        try {
            $payload = $this->jwtService->decode($validated['refresh_token']);
        } catch (\Throwable $exception) {
            return response()->json(['message' => $exception->getMessage()], 401);
        }

        if (($payload['type'] ?? null) !== 'refresh') {
            return response()->json(['message' => 'Invalid refresh token type.'], 401);
        }

        $jti = (string) ($payload['jti'] ?? '');
        $userId = (int) ($payload['sub'] ?? 0);

        $refreshToken = RefreshToken::query()
            ->where('jti', $jti)
            ->where('user_id', $userId)
            ->first();

        if (!$refreshToken) {
            return response()->json(['message' => 'Refresh token is not recognized.'], 401);
        }

        if ($refreshToken->revoked_at !== null || $refreshToken->expires_at->isPast()) {
            return response()->json(['message' => 'Refresh token is no longer valid.'], 401);
        }

        if (!hash_equals($refreshToken->token_hash, hash('sha256', $validated['refresh_token']))) {
            return response()->json(['message' => 'Refresh token hash mismatch.'], 401);
        }

        $user = User::query()->find($userId);

        if (!$user) {
            return response()->json(['message' => 'User not found.'], 401);
        }

        $refreshToken->update([
            'revoked_at' => CarbonImmutable::now(),
        ]);

        return response()->json($this->issueTokens($user, $validated['device_name'] ?? null));
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        $progress = UserProgress::query()
            ->where('user_id', $user->id)
            ->first();

        $recentAttempts = QuestAttempt::query()
            ->join('quests', 'quests.id', '=', 'quest_attempts.quest_id')
            ->where('quest_attempts.user_id', $user->id)
            ->orderByDesc('quest_attempts.completed_at')
            ->limit(8)
            ->get([
                'quest_attempts.id',
                'quest_attempts.quest_id',
                'quest_attempts.score',
                'quest_attempts.is_correct',
                'quest_attempts.completed_at',
                'quests.title as quest_title',
                'quests.type as quest_type',
            ]);

        $voucherSummary = [
            'pending' => Voucher::query()
                ->where('user_id', $user->id)
                ->where('status', 'pending')
                ->count(),
            'active' => Voucher::query()
                ->where('user_id', $user->id)
                ->where('status', 'active')
                ->count(),
            'redeemed' => Voucher::query()
                ->where('user_id', $user->id)
                ->where('status', 'redeemed')
                ->count(),
            'expired' => Voucher::query()
                ->where('user_id', $user->id)
                ->where('status', 'expired')
                ->count(),
            'total' => Voucher::query()
                ->where('user_id', $user->id)
                ->count(),
        ];

        return response()->json([
            'data' => $user,
            'progress' => [
                'tier' => $progress?->tier ?? 'Iron',
                'points' => (int) ($progress?->points ?? 0),
                'quests_completed' => (int) ($progress?->quests_completed ?? 0),
                'last_activity_at' => $progress?->last_activity_at,
            ],
            'voucher_summary' => $voucherSummary,
            'recent_activity' => $recentAttempts,
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();

        RefreshToken::query()
            ->where('user_id', $user->id)
            ->whereNull('revoked_at')
            ->update(['revoked_at' => CarbonImmutable::now()]);

        return response()->json([
            'message' => 'Logged out successfully.',
        ]);
    }

    private function issueTokens(User $user, ?string $deviceName): array
    {
        $jti = (string) Str::uuid();
        $accessToken = $this->jwtService->createAccessToken($user->id, $user->email, $user->role);
        $refreshToken = $this->jwtService->createRefreshToken($user->id, $jti);

        RefreshToken::query()->create([
            'user_id' => $user->id,
            'jti' => $jti,
            'token_hash' => hash('sha256', $refreshToken),
            'expires_at' => CarbonImmutable::now()->addDays(30),
            'device_name' => $deviceName ?: 'unknown-device',
        ]);

        return [
            'access_token' => $accessToken,
            'refresh_token' => $refreshToken,
            'token_type' => 'Bearer',
            'expires_in' => 1800,
            'user' => $user,
        ];
    }
}
