<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('quests', function (Blueprint $table): void {
            $table->id();
            $table->string('title');
            $table->string('type', 50);
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->unsignedInteger('points')->default(0);
            $table->string('status', 30)->default('approach_to_unlock');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('quests');
    }
};
