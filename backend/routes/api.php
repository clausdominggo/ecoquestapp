<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\QuestController;
use App\Http\Controllers\Api\VoucherController;
use App\Http\Controllers\Api\VisitorController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/refresh', [AuthController::class, 'refresh']);

    Route::middleware('jwt.auth')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

Route::middleware('jwt.auth')->group(function () {
    Route::get('/quests', [QuestController::class, 'index']);
    Route::post('/quests/{quest}/unlock', [QuestController::class, 'unlock']);
    Route::post('/quests/{quest}/verify-qr', [QuestController::class, 'verifyQr']);
    Route::post('/quests/{quest}/submit-quiz', [QuestController::class, 'submitQuiz']);
    Route::post('/quests/{quest}/complete', [QuestController::class, 'complete']);
    Route::post('/visitor/location', [VisitorController::class, 'updateLocation']);

    Route::get('/vouchers', [VoucherController::class, 'index']);
    Route::get('/vouchers/{voucher}', [VoucherController::class, 'show']);
    Route::post('/vouchers/{voucher}/review', [VoucherController::class, 'submitReview']);
    Route::post('/vouchers/{voucher}/redeem', [VoucherController::class, 'redeem']);
});
