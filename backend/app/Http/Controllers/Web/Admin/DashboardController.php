<?php

namespace App\Http\Controllers\Web\Admin;

use App\Http\Controllers\Controller;
use App\Models\ParticipantLocation;
use App\Models\Quest;
use App\Models\QuestAttempt;
use App\Models\Voucher;
use App\Models\User;
use App\Models\UserProgress;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function index(): View
    {
        return view('admin.dashboard');
    }

    public function metrics(): JsonResponse
    {
        $today = CarbonImmutable::today();

        $registrations = User::query()->whereDate('created_at', '>=', $today)->count();
        $activeParticipants = UserProgress::query()->where('last_activity_at', '>=', CarbonImmutable::now()->subMinutes(15))->count();
        $activeAdmins = ParticipantLocation::query()
            ->join('users', 'users.id', '=', 'participant_locations.user_id')
            ->where('users.role', 'admin')
            ->where('participant_locations.is_active', true)
            ->where('participant_locations.recorded_at', '>=', CarbonImmutable::now()->subMinutes(15))
            ->distinct('participant_locations.user_id')
            ->count('participant_locations.user_id');
        $questsCompletedToday = QuestAttempt::query()->whereDate('completed_at', $today)->count();
        $vouchersRedeemed = Voucher::query()->where('status', 'redeemed')->count();

        return response()->json([
            'total_registrations' => $registrations,
            'total_active_participants' => $activeParticipants,
            'total_active_admins' => $activeAdmins,
            'total_quests_completed_today' => $questsCompletedToday,
            'total_vouchers_redeemed' => $vouchersRedeemed,
        ]);
    }

    public function activeMap(): JsonResponse
    {
        return response()->json([
            'participants' => $this->latestLocationsForRole('visitor'),
            'admins' => $this->latestLocationsForRole('admin'),
            'quests' => Quest::query()
                ->where('is_active', true)
                ->orderBy('id')
                ->get([
                    'id',
                    'title',
                    'type',
                    'mode',
                    'latitude',
                    'longitude',
                    'points',
                    'status',
                    'unlock_radius_m',
                    'accuracy_threshold_m',
                ]),
        ]);
    }

    public function recordLocation(Request $request): JsonResponse
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

        return response()->json([
            'message' => 'Admin location updated.',
        ]);
    }

    public function tierDistribution(): JsonResponse
    {
        $rows = UserProgress::query()
            ->select('tier', DB::raw('COUNT(*) as total'))
            ->groupBy('tier')
            ->orderBy('tier')
            ->get();

        return response()->json(['data' => $rows]);
    }

    public function questCompletions(): JsonResponse
    {
        $start = CarbonImmutable::today()->subDays(6);

        $rows = QuestAttempt::query()
            ->selectRaw('DATE(completed_at) as date, COUNT(*) as total')
            ->whereDate('completed_at', '>=', $start)
            ->groupByRaw('DATE(completed_at)')
            ->orderByRaw('DATE(completed_at)')
            ->get();

        return response()->json(['data' => $rows]);
    }

    public function leaderboard(): JsonResponse
    {
        $rows = User::query()
            ->leftJoin('user_progress', 'users.id', '=', 'user_progress.user_id')
            ->select([
                'users.id',
                'users.name',
                DB::raw("COALESCE(user_progress.tier, 'Iron') as tier"),
                DB::raw('COALESCE(user_progress.points, 0) as points'),
                DB::raw('COALESCE(user_progress.quests_completed, 0) as quests_completed'),
                'user_progress.last_activity_at',
            ])
            ->where('users.role', 'visitor')
            ->orderByDesc('points')
            ->orderBy('users.name')
            ->get();

        return response()->json(['data' => $rows]);
    }

    private function latestLocationsForRole(string $role)
    {
        $latestPerUser = ParticipantLocation::query()
            ->select('user_id', DB::raw('MAX(recorded_at) as max_recorded'))
            ->join('users', 'users.id', '=', 'participant_locations.user_id')
            ->where('users.role', $role)
            ->groupBy('user_id');

        return ParticipantLocation::query()
            ->joinSub($latestPerUser, 'latest_per_user', function ($join): void {
                $join->on('participant_locations.user_id', '=', 'latest_per_user.user_id')
                    ->on('participant_locations.recorded_at', '=', 'latest_per_user.max_recorded');
            })
            ->join('users', 'users.id', '=', 'participant_locations.user_id')
            ->where('participant_locations.is_active', true)
            ->select([
                'participant_locations.user_id',
                'participant_locations.latitude',
                'participant_locations.longitude',
                'participant_locations.accuracy',
                'participant_locations.speed',
                'participant_locations.recorded_at',
                'users.name',
                'users.role',
            ])
            ->orderBy('users.name')
            ->get();
    }

    public function exportLeaderboardCsv()
    {
        $rows = User::query()
            ->leftJoin('user_progress', 'users.id', '=', 'user_progress.user_id')
            ->select([
                'users.name',
                DB::raw("COALESCE(user_progress.tier, 'Iron') as tier"),
                DB::raw('COALESCE(user_progress.points, 0) as points'),
                DB::raw('COALESCE(user_progress.quests_completed, 0) as quests_completed'),
                'user_progress.last_activity_at',
            ])
            ->where('users.role', 'visitor')
            ->orderByDesc('points')
            ->get();

        $csv = "rank,name,tier,points,quests_completed,last_activity\n";

        foreach ($rows as $index => $row) {
            $rank = $index + 1;
            $csv .= sprintf(
                "%d,%s,%s,%d,%d,%s\n",
                $rank,
                str_replace(',', ' ', $row->name),
                $row->tier,
                (int) $row->points,
                (int) $row->quests_completed,
                (string) ($row->last_activity_at ?? '')
            );
        }

        return response($csv, 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="leaderboard.csv"',
        ]);
    }
}
