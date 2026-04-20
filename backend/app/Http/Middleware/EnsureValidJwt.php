<?php

namespace App\Http\Middleware;

use App\Models\User;
use App\Support\JwtService;
use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureValidJwt
{
    public function __construct(private readonly JwtService $jwtService)
    {
    }

    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();

        if (!$token) {
            return new JsonResponse(['message' => 'Missing bearer token.'], 401);
        }

        try {
            $payload = $this->jwtService->decode($token);
        } catch (\Throwable $exception) {
            return new JsonResponse(['message' => $exception->getMessage()], 401);
        }

        if (($payload['type'] ?? null) !== 'access') {
            return new JsonResponse(['message' => 'Invalid access token.'], 401);
        }

        $user = User::query()->find($payload['sub'] ?? 0);

        if (!$user) {
            return new JsonResponse(['message' => 'User not found.'], 401);
        }

        $request->attributes->set('token_payload', $payload);
        $request->setUserResolver(static fn (): User => $user);

        return $next($request);
    }
}
