<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ParticipantLocation;
use App\Models\Quest;
use App\Models\QuestAttempt;
use App\Models\Voucher;
use App\Models\UserProgress;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QuestController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'data' => Quest::query()->where('is_active', true)->orderBy('id')->get(),
        ]);
    }

    public function unlock(Request $request, Quest $quest): JsonResponse
    {
        $validated = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'accuracy' => ['nullable', 'numeric', 'min:0'],
            'speed' => ['nullable', 'numeric', 'min:0'],
        ]);

        $distanceMeters = $this->distanceMeters(
            (float) $validated['latitude'],
            (float) $validated['longitude'],
            (float) $quest->latitude,
            (float) $quest->longitude,
        );

        $accuracy = isset($validated['accuracy']) ? (float) $validated['accuracy'] : null;
        $radiusOk = $distanceMeters <= (float) $quest->unlock_radius_m;
        $accuracyOk = $accuracy === null || $accuracy <= (float) $quest->accuracy_threshold_m;

        ParticipantLocation::query()->create([
            'user_id' => $request->user()->id,
            'latitude' => (float) $validated['latitude'],
            'longitude' => (float) $validated['longitude'],
            'accuracy' => $accuracy,
            'speed' => isset($validated['speed']) ? (float) $validated['speed'] : null,
            'is_active' => true,
            'recorded_at' => CarbonImmutable::now(),
        ]);

        $unlockReady = $radiusOk && $accuracyOk;

        return response()->json([
            'unlock_ready' => $unlockReady,
            'distance_m' => round($distanceMeters, 2),
            'accuracy_m' => $accuracy,
            'required_radius_m' => (float) $quest->unlock_radius_m,
            'required_accuracy_m' => (float) $quest->accuracy_threshold_m,
            'requires_qr' => $quest->qr_code !== null,
            'mode' => $quest->mode,
            'instruction' => $quest->instruction,
            'quest' => $quest,
        ]);
    }

    public function verifyQr(Request $request, Quest $quest): JsonResponse
    {
        $validated = $request->validate([
            'code' => ['required', 'string', 'max:255'],
        ]);

        if ($quest->qr_code === null) {
            return response()->json([
                'verified' => true,
                'message' => 'Quest tidak memerlukan QR.',
            ]);
        }

        $verified = hash_equals((string) $quest->qr_code, trim((string) $validated['code']));

        return response()->json([
            'verified' => $verified,
            'message' => $verified ? 'QR valid.' : 'QR tidak cocok.',
        ], $verified ? 200 : 422);
    }

    public function submitQuiz(Request $request, Quest $quest): JsonResponse
    {
        $validated = $request->validate([
            'answer' => ['required', 'string', 'max:255'],
            'timed_out' => ['nullable', 'boolean'],
        ]);

        $isCorrect = !$validated['timed_out'] && strcasecmp(trim($validated['answer']), (string) ($quest->quiz_answer ?? '')) === 0;
        $score = $isCorrect ? (int) $quest->points : 0;

        return $this->recordQuestCompletion(
            request: $request,
            quest: $quest,
            score: $score,
            isCorrect: $isCorrect,
            responseMessage: $isCorrect
                ? 'Jawaban tepat, quest berhasil diselesaikan.'
                : 'Jawaban belum tepat, coba quest lain untuk menambah poin.',
        );
    }

    public function complete(Request $request, Quest $quest): JsonResponse
    {
        $validated = $request->validate([
            'score' => ['required', 'integer', 'min:0'],
            'is_correct' => ['nullable', 'boolean'],
            'summary' => ['nullable', 'string', 'max:255'],
            'timed_out' => ['nullable', 'boolean'],
        ]);

        $score = (int) $validated['score'];
        $isCorrect = (bool) ($validated['is_correct'] ?? ($score > 0));

        if (isset($validated['timed_out']) && $validated['timed_out']) {
            $isCorrect = false;
        }

        return $this->recordQuestCompletion(
            request: $request,
            quest: $quest,
            score: $score,
            isCorrect: $isCorrect,
            responseMessage: (string) ($validated['summary'] ?? 'Quest selesai dan progress berhasil diperbarui.'),
        );
    }

    private function recordQuestCompletion(
        Request $request,
        Quest $quest,
        int $score,
        bool $isCorrect,
        string $responseMessage,
    ): JsonResponse {
        QuestAttempt::query()->create([
            'user_id' => $request->user()->id,
            'quest_id' => $quest->id,
            'status' => 'completed',
            'score' => $score,
            'is_correct' => $isCorrect,
            'completed_at' => CarbonImmutable::now(),
        ]);

        $progress = UserProgress::query()->firstOrCreate(
            ['user_id' => $request->user()->id],
            [
                'tier' => 'Iron',
                'points' => 0,
                'quests_completed' => 0,
            ]
        );

        $oldTier = (string) $progress->tier;
        $newPoints = (int) $progress->points + $score;
        $newCompleted = (int) $progress->quests_completed + 1;
        $newTier = $this->resolveTier($newPoints);
        $tierChanged = $newTier !== $oldTier;

        $progress->update([
            'points' => $newPoints,
            'quests_completed' => $newCompleted,
            'tier' => $newTier,
            'last_activity_at' => CarbonImmutable::now(),
        ]);

        $voucher = null;

        if ($tierChanged && $newTier !== 'Iron') {
            $voucher = Voucher::query()->create([
                'user_id' => $request->user()->id,
                'code' => sprintf(
                    'VCR-%s-%s-%s',
                    strtoupper(substr($newTier, 0, 3)),
                    $quest->id,
                    $request->user()->id,
                ),
                'tier' => $newTier,
                'reward_type' => sprintf('%s Tier Reward Voucher', $newTier),
                'status' => 'pending',
            ]);
        }

        return response()->json([
            'is_correct' => $isCorrect,
            'score' => $score,
            'message' => $responseMessage,
            'progress' => [
                'tier' => $newTier,
                'tier_changed' => $tierChanged,
                'old_tier' => $oldTier,
                'points' => $newPoints,
                'quests_completed' => $newCompleted,
            ],
            'voucher_awarded' => $voucher ? [
                'id' => $voucher->id,
                'code' => $voucher->code,
                'tier' => $voucher->tier,
                'reward_type' => $voucher->reward_type,
                'status' => $voucher->status,
            ] : null,
        ]);
    }

    private function resolveTier(int $points): string
    {
        return match (true) {
            $points >= 1000 => 'Gold',
            $points >= 600 => 'Silver',
            $points >= 300 => 'Bronze',
            default => 'Iron',
        };
    }

    private function distanceMeters(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earthRadius = 6371000;
        $deltaLat = deg2rad($lat2 - $lat1);
        $deltaLng = deg2rad($lng2 - $lng1);
        $a = sin($deltaLat / 2) * sin($deltaLat / 2)
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2))
            * sin($deltaLng / 2) * sin($deltaLng / 2);

        return $earthRadius * 2 * atan2(sqrt($a), sqrt(1 - $a));
    }
}
