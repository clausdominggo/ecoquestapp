<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Voucher;
use Carbon\CarbonImmutable;
use Illuminate\Database\Seeder;

class VoucherSeeder extends Seeder
{
    public function run(): void
    {
        $visitor = User::query()->where('email', 'test@example.com')->first();

        if (! $visitor) {
            return;
        }

        $vouchers = [
            [
                'code' => 'VCR-BRZ-2401',
                'tier' => 'Bronze',
                'reward_type' => 'Diskon minuman sehat 20%',
                'status' => 'pending',
                'review_score' => null,
                'review_comment' => null,
                'activated_at' => null,
                'redeemed_at' => null,
            ],
            [
                'code' => 'VCR-SLV-2411',
                'tier' => 'Silver',
                'reward_type' => 'Eco tumbler exclusive',
                'status' => 'active',
                'review_score' => 5,
                'review_comment' => 'Voucher sudah aktif dan mudah dipakai.',
                'activated_at' => CarbonImmutable::now()->subDays(6),
                'redeemed_at' => null,
            ],
            [
                'code' => 'VCR-GLD-2403',
                'tier' => 'Gold',
                'reward_type' => 'Free workshop pass',
                'status' => 'redeemed',
                'review_score' => 4,
                'review_comment' => 'Proses redeem lancar.',
                'activated_at' => CarbonImmutable::now()->subDays(11),
                'redeemed_at' => CarbonImmutable::now()->subDays(9),
            ],
            [
                'code' => 'VCR-IRN-2409',
                'tier' => 'Iron',
                'reward_type' => 'Voucher badge profile',
                'status' => 'expired',
                'review_score' => null,
                'review_comment' => null,
                'activated_at' => null,
                'redeemed_at' => null,
            ],
        ];

        foreach ($vouchers as $voucher) {
            Voucher::query()->updateOrCreate(
                ['code' => $voucher['code']],
                [
                    'user_id' => $visitor->id,
                    ...$voucher,
                ]
            );
        }
    }
}
