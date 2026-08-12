<?php

declare(strict_types=1);

use App\Http\Controllers\Api\AgendaController;
use App\Http\Controllers\Api\AnnouncementController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\LiturgyController;
use App\Http\Controllers\Api\MovementController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ParishController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ProfileController;
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

// CinetPay callbacks — public (server-to-server webhook + browser return page).
Route::post('payments/cinetpay/notify', [PaymentController::class, 'notify']);
Route::match(['get', 'post'], 'payments/cinetpay/return', [PaymentController::class, 'returnPage']);

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

    // Notification center (bell icon): parish feed against a read watermark.
    Route::get('notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::post('notifications/read', [NotificationController::class, 'markRead']);

    // Aggregated home screen (liturgy of the day + parish schedule + headline).
    Route::get('home', [HomeController::class, 'index']);

    // Liturgy of the day (and any date) — auto-filled from AELF.
    Route::get('liturgy', [LiturgyController::class, 'today']);
    Route::get('liturgy/{date}', [LiturgyController::class, 'show'])->where('date', '\d{4}-\d{2}-\d{2}');

    // Agenda — major liturgical feasts (LitCal) + parish events.
    Route::get('agenda', [AgendaController::class, 'index']);
    Route::post('agenda/events/{event}/rsvp', [AgendaController::class, 'toggleRsvp'])->whereNumber('event');

    // Profile — edit identity/avatar and app preferences.
    Route::post('profile', [ProfileController::class, 'update']);
    Route::put('profile/preferences', [ProfileController::class, 'updatePreferences']);

    // Fundraising campaigns (dons/cotisations/quêtes) of the parish.
    Route::get('campaigns', [\App\Http\Controllers\Api\CampaignController::class, 'index']);
    Route::post('campaigns/{campaign}/pledge', [\App\Http\Controllers\Api\CampaignController::class, 'pledge'])->whereNumber('campaign');

    // Movements (groups) — list, detail, join/leave, mine.
    Route::get('movements', [MovementController::class, 'index']);
    Route::get('my-movements', [MovementController::class, 'mine']);
    Route::get('movements/{movement}', [MovementController::class, 'show'])->whereNumber('movement');
    Route::post('movements/{movement}/join', [MovementController::class, 'join'])->whereNumber('movement');
    Route::delete('movements/{movement}/leave', [MovementController::class, 'leave'])->whereNumber('movement');

    // Spiritual content (Prières & Chapelets) for "Vie & Foi".
    Route::get('prayers', [\App\Http\Controllers\Api\PrayerController::class, 'index']);

    // Saint of the day (AELF + Wikipedia FR).
    Route::get('saints', [\App\Http\Controllers\Api\SaintController::class, 'today']);
    Route::get('saints/{date}', [\App\Http\Controllers\Api\SaintController::class, 'show'])->where('date', '\d{4}-\d{2}-\d{2}');

    // Prayer intentions wall (parish community).
    Route::get('intentions', [\App\Http\Controllers\Api\PrayerIntentionController::class, 'index']);
    Route::post('intentions', [\App\Http\Controllers\Api\PrayerIntentionController::class, 'store'])->middleware('throttle:20,1');
    Route::post('intentions/{intention}/pray', [\App\Http\Controllers\Api\PrayerIntentionController::class, 'pray'])->whereNumber('intention');
    Route::delete('intentions/{intention}', [\App\Http\Controllers\Api\PrayerIntentionController::class, 'destroy'])->whereNumber('intention');

    // Payments (Mobile Money / card via CinetPay): mass requests, quête, don…
    Route::get('payments/options', [PaymentController::class, 'options']);
    Route::get('payments/mine', [PaymentController::class, 'mine']);
    Route::post('payments', [PaymentController::class, 'store']);
    Route::get('payments/{reference}', [PaymentController::class, 'show'])->where('reference', 'ECC-[A-Za-z0-9\-]+');
});
