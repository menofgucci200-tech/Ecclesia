<?php

declare(strict_types=1);

use App\Http\Controllers\Api\AnnouncementController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ParishController;
use App\Http\Controllers\Api\UserParishController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — Ecclesia
|--------------------------------------------------------------------------
*/

Route::prefix('auth')->group(function () {
    // Public — credential endpoints (rate limited).
    Route::post('check-phone', [AuthController::class, 'checkPhone'])->middleware('throttle:auth');
    Route::post('login', [AuthController::class, 'login'])->middleware('throttle:auth');
    Route::post('register', [AuthController::class, 'register'])->middleware('throttle:register');
    Route::post('forgot-password', [AuthController::class, 'forgotPassword'])->middleware('throttle:auth');
    Route::post('reset-password', [AuthController::class, 'resetPassword'])->middleware('throttle:auth');

    // Protected — an authenticated session is required.
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
        Route::post('change-password', [AuthController::class, 'changePassword']);
    });
});

Route::middleware('auth:sanctum')->group(function () {
    // Parish discovery (order matters: static segments before the wildcard).
    Route::get('parishes', [ParishController::class, 'index']);
    Route::get('parishes/search', [ParishController::class, 'search']);
    Route::get('parishes/{parish}', [ParishController::class, 'show'])->whereNumber('parish');

    // The authenticated faithful's parish membership.
    Route::get('user/parish', [UserParishController::class, 'show']);
    Route::post('user/parish', [UserParishController::class, 'store']);

    // The parish feed ("Fil paroissial") for the authenticated faithful.
    Route::get('parish/announcements', [AnnouncementController::class, 'index']);
});
