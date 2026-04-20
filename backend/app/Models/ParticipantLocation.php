<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ParticipantLocation extends Model
{
    protected $fillable = [
        'user_id',
        'latitude',
        'longitude',
        'accuracy',
        'speed',
        'is_active',
        'recorded_at',
    ];

    protected function casts(): array
    {
        return [
            'recorded_at' => 'datetime',
            'is_active' => 'boolean',
        ];
    }
}
