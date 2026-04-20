<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QuestAttempt extends Model
{
    protected $fillable = [
        'user_id',
        'quest_id',
        'status',
        'score',
        'is_correct',
        'completed_at',
    ];

    protected function casts(): array
    {
        return [
            'completed_at' => 'datetime',
            'is_correct' => 'boolean',
        ];
    }
}
