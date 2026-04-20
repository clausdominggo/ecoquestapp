<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ParticipantLocation;
use App\Models\UserProgress;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VisitorController extends Controller
{
    public function updateLocation(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'accuracy' => ['nullable', 'numeric', 'min:0'],
            'speed' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $user = $request->user();

        ParticipantLocation::query()->create([
            'user_id' => $user->id,
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
            'accuracy' => $validated['accuracy'] ?? null,
            'speed' => $validated['speed'] ?? null,
            'is_active' => $validated['is_active'] ?? true,
            'recorded_at' => CarbonImmutable::now(),
        ]);

        UserProgress::query()->updateOrCreate([
            'user_id' => $user->id,
        ], [
            'last_activity_at' => CarbonImmutable::now(),
        ]);

        return response()->json([
            'message' => 'Location updated.',
        ]);
    }
}
