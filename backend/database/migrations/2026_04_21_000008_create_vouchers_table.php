<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vouchers', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('code', 100)->unique();
            $table->string('tier', 20)->default('Iron');
            $table->string('reward_type', 255);
            $table->string('status', 20)->default('pending');
            $table->unsignedTinyInteger('review_score')->nullable();
            $table->text('review_comment')->nullable();
            $table->timestamp('activated_at')->nullable();
            $table->timestamp('redeemed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vouchers');
    }
};
