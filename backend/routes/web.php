<?php

use App\Http\Controllers\Web\Admin\AuthController;
use App\Http\Controllers\Web\Admin\DashboardController;
use App\Http\Controllers\Web\Admin\QuestManagementController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('admin.login');
});

Route::prefix('admin')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin']);
    Route::post('/login', [AuthController::class, 'login']);

    Route::middleware('admin.session')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);

        Route::get('/dashboard', [DashboardController::class, 'index']);
        Route::get('/api/metrics', [DashboardController::class, 'metrics']);
        Route::get('/api/active-map', [DashboardController::class, 'activeMap']);
        Route::post('/api/location', [DashboardController::class, 'recordLocation']);
        Route::get('/api/tier-distribution', [DashboardController::class, 'tierDistribution']);
        Route::get('/api/quest-completions', [DashboardController::class, 'questCompletions']);
        Route::get('/api/leaderboard', [DashboardController::class, 'leaderboard']);
        Route::get('/api/leaderboard/export', [DashboardController::class, 'exportLeaderboardCsv']);

        Route::get('/quests', [QuestManagementController::class, 'index']);
        Route::post('/quests', [QuestManagementController::class, 'store']);
        Route::put('/quests/{quest}', [QuestManagementController::class, 'update']);
        Route::delete('/quests/{quest}', [QuestManagementController::class, 'destroy']);
    });
});
