<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Voucher extends Model
{
    protected $fillable = [
        'user_id',
        'code',
        'tier',
        'reward_type',
        'status',
        'review_score',
        'review_comment',
        'activated_at',
        'redeemed_at',
    ];

    protected function casts(): array
    {
        return [
            'review_score' => 'integer',
            'activated_at' => 'datetime',
            'redeemed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
