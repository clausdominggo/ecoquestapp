<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('quest_attempts', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('quest_id')->constrained()->cascadeOnDelete();
            $table->string('status', 20)->default('completed');
            $table->unsignedInteger('score')->default(0);
            $table->boolean('is_correct')->default(false);
            $table->timestamp('completed_at');
            $table->timestamps();

            $table->index(['completed_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('quest_attempts');
    }
};
