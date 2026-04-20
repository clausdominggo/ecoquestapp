<?php

namespace App\Support;

use Carbon\CarbonImmutable;
use RuntimeException;

class JwtService
{
    public function createAccessToken(int $userId, string $email, string $role): string
    {
        return $this->encode([
            'sub' => $userId,
            'email' => $email,
            'role' => $role,
            'type' => 'access',
            'iat' => CarbonImmutable::now()->timestamp,
            'exp' => CarbonImmutable::now()->addMinutes(30)->timestamp,
        ]);
    }

    public function createRefreshToken(int $userId, string $jti): string
    {
        return $this->encode([
            'sub' => $userId,
            'type' => 'refresh',
            'jti' => $jti,
            'iat' => CarbonImmutable::now()->timestamp,
            'exp' => CarbonImmutable::now()->addDays(30)->timestamp,
        ]);
    }

    public function decode(string $token): array
    {
        $segments = explode('.', $token);

        if (count($segments) !== 3) {
            throw new RuntimeException('Invalid token format.');
        }

        [$headerEncoded, $payloadEncoded, $signatureEncoded] = $segments;

        $header = json_decode($this->base64UrlDecode($headerEncoded), true);
        $payload = json_decode($this->base64UrlDecode($payloadEncoded), true);

        if (!is_array($header) || !is_array($payload)) {
            throw new RuntimeException('Invalid token payload.');
        }

        $expectedSignature = $this->base64UrlEncode(
            hash_hmac('sha256', "$headerEncoded.$payloadEncoded", $this->secret(), true)
        );

        if (!hash_equals($expectedSignature, $signatureEncoded)) {
            throw new RuntimeException('Invalid token signature.');
        }

        if (($payload['exp'] ?? 0) < CarbonImmutable::now()->timestamp) {
            throw new RuntimeException('Token expired.');
        }

        return $payload;
    }

    public function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }

    private function encode(array $payload): string
    {
        $header = [
            'alg' => 'HS256',
            'typ' => 'JWT',
        ];

        $headerEncoded = $this->base64UrlEncode((string) json_encode($header));
        $payloadEncoded = $this->base64UrlEncode((string) json_encode($payload));
        $signatureEncoded = $this->base64UrlEncode(
            hash_hmac('sha256', "$headerEncoded.$payloadEncoded", $this->secret(), true)
        );

        return "$headerEncoded.$payloadEncoded.$signatureEncoded";
    }

    private function base64UrlDecode(string $value): string
    {
        $padded = str_pad($value, strlen($value) % 4 === 0 ? strlen($value) : strlen($value) + 4 - strlen($value) % 4, '=', STR_PAD_RIGHT);

        return (string) base64_decode(strtr($padded, '-_', '+/'));
    }

    private function secret(): string
    {
        $secret = env('JWT_SECRET');

        if (is_string($secret) && $secret !== '') {
            return $secret;
        }

        $fallback = (string) config('app.key');

        if ($fallback === '') {
            throw new RuntimeException('JWT secret is not configured.');
        }

        return $fallback;
    }
}
