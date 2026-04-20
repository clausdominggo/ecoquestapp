<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('quests', function (Blueprint $table): void {
            $table->string('mode', 30)->default('gps')->after('type');
            $table->decimal('unlock_radius_m', 8, 2)->default(25)->after('points');
            $table->decimal('accuracy_threshold_m', 8, 2)->default(15)->after('unlock_radius_m');
            $table->string('qr_code', 120)->nullable()->after('accuracy_threshold_m');
            $table->text('instruction')->nullable()->after('qr_code');
            $table->text('quiz_question')->nullable()->after('instruction');
            $table->json('quiz_options')->nullable()->after('quiz_question');
            $table->string('quiz_answer', 255)->nullable()->after('quiz_options');
            $table->unsignedInteger('timer_seconds')->default(60)->after('quiz_answer');
            $table->boolean('is_active')->default(true)->after('timer_seconds');
        });
    }

    public function down(): void
    {
        Schema::table('quests', function (Blueprint $table): void {
            $table->dropColumn([
                'mode',
                'unlock_radius_m',
                'accuracy_threshold_m',
                'qr_code',
                'instruction',
                'quiz_question',
                'quiz_options',
                'quiz_answer',
                'timer_seconds',
                'is_active',
            ]);
        });
    }
};
