<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Quest extends Model
{
    protected $fillable = [
        'title',
        'type',
        'mode',
        'latitude',
        'longitude',
        'points',
        'unlock_radius_m',
        'accuracy_threshold_m',
        'qr_code',
        'instruction',
        'quiz_question',
        'quiz_options',
        'quiz_answer',
        'timer_seconds',
        'is_active',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'quiz_options' => 'array',
            'is_active' => 'boolean',
        ];
    }
}
