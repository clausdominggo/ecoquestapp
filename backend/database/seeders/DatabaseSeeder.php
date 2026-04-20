<?php

namespace Database\Seeders;

use App\Models\ParticipantLocation;
use App\Models\Quest;
use App\Models\QuestAttempt;
use App\Models\User;
use App\Models\UserProgress;
use Carbon\CarbonImmutable;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::query()->updateOrCreate([
            'email' => 'test@example.com',
        ], [
            'name' => 'Test User',
            'phone' => '+6281212345678',
            'role' => 'visitor',
            'password' => Hash::make('password123'),
        ]);

        User::query()->updateOrCreate([
            'email' => 'admin@example.com',
        ], [
            'name' => 'Admin User',
            'phone' => '+6281211111111',
            'role' => 'admin',
            'password' => Hash::make('password123'),
        ]);

        User::query()->updateOrCreate([
            'email' => 'dashboard@ecoquest.local',
        ], [
            'name' => 'Dashboard Admin',
            'phone' => '+6281234567899',
            'role' => 'admin',
            'password' => Hash::make('EcoQuest123!'),
        ]);

        User::query()->updateOrCreate([
            'email' => 'staff@example.com',
        ], [
            'name' => 'Staff User',
            'phone' => '+6281222222222',
            'role' => 'staff',
            'password' => Hash::make('password123'),
        ]);

        $this->call([
            QuestSeeder::class,
            VoucherSeeder::class,
        ]);

        $visitor = User::query()->where('email', 'test@example.com')->first();

        if ($visitor) {
            UserProgress::query()->updateOrCreate([
                'user_id' => $visitor->id,
            ], [
                'tier' => 'Bronze',
                'points' => 420,
                'quests_completed' => 14,
                'last_activity_at' => CarbonImmutable::now()->subMinutes(3),
            ]);

            ParticipantLocation::query()->create([
                'user_id' => $visitor->id,
                'latitude' => -6.59855,
                'longitude' => 106.79912,
                'accuracy' => 7.5,
                'speed' => 0.9,
                'is_active' => true,
                'recorded_at' => CarbonImmutable::now()->subMinutes(1),
            ]);

            $quests = Quest::query()->limit(3)->get();

            foreach (range(0, 6) as $dayOffset) {
                $quest = $quests[$dayOffset % max($quests->count(), 1)] ?? null;

                if (!$quest) {
                    continue;
                }

                QuestAttempt::query()->create([
                    'user_id' => $visitor->id,
                    'quest_id' => $quest->id,
                    'status' => 'completed',
                    'score' => (int) $quest->points,
                    'is_correct' => true,
                    'completed_at' => CarbonImmutable::today()->subDays($dayOffset)->addHours(10),
                ]);
            }
        }
    }
}
