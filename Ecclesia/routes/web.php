<?php

declare(strict_types=1);

use App\Http\Controllers\Admin\AnnouncementController;
use App\Http\Controllers\Admin\Auth\LoginController;
use App\Http\Controllers\Admin\CampaignController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\HomeController;
use App\Http\Controllers\Admin\LiturgicalCalendarController;
use App\Http\Controllers\Admin\LiturgyController;
use App\Http\Controllers\Admin\MassIntentionController;
use App\Http\Controllers\Admin\MassTimeController;
use App\Http\Controllers\Admin\MemberController;
use App\Http\Controllers\Admin\MovementController;
use App\Http\Controllers\Admin\ParishController;
use App\Http\Controllers\Admin\ParishEventController;
use App\Http\Controllers\Admin\PaymentController as PaymentAdminController;
use App\Http\Controllers\Admin\PaymentSettingsController;
use App\Http\Controllers\Admin\PrayerController;
use App\Http\Controllers\Admin\PrayerIntentionController as PrayerIntentionAdminController;
use App\Http\Controllers\Admin\SaintController;
use Illuminate\Support\Facades\Route;

Route::get('/', HomeController::class)->name('home');

/*
|--------------------------------------------------------------------------
| Administration dashboards (two separate session-based areas)
|--------------------------------------------------------------------------
| /admin  → parish administrators (scoped to their own parish)
| /super  → platform super administrators (every parish + parish directory)
| Both areas share the same controllers and Blade views; link generation is
| resolved per-role by the admin_route() helper.
*/

/** Register the routes shared by both areas (dashboard, members, announcements). */
$sharedAdminRoutes = function (string $roleScope): void {
    Route::middleware('admin:'.$roleScope)->group(function () {
        Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

        // Members (faithful).
        Route::get('members', [MemberController::class, 'index'])->name('members.index');
        Route::get('members/{member}', [MemberController::class, 'show'])->name('members.show');
        Route::patch('members/{member}/status', [MemberController::class, 'updateStatus'])->name('members.status');

        // Announcements (parish feed consumed by the mobile app).
        Route::resource('announcements', AnnouncementController::class)->except(['show']);

        // Mass schedule (parish admins manage their own parish).
        Route::get('mass-times', [MassTimeController::class, 'index'])->name('mass-times.index');
        Route::post('mass-times', [MassTimeController::class, 'store'])->name('mass-times.store');
        Route::patch('mass-times/{massTime}', [MassTimeController::class, 'update'])->name('mass-times.update');
        Route::delete('mass-times/{massTime}', [MassTimeController::class, 'destroy'])->name('mass-times.destroy');

        // Parish events (agenda) managed by the parish admin.
        Route::resource('events', ParishEventController::class)->except(['show']);

        // Parish movements (groups) managed by the parish admin.
        Route::resource('movements', MovementController::class)->except(['show']);

        // Fundraising campaigns (dons / cotisations / quêtes).
        Route::resource('campaigns', CampaignController::class)->except(['show']);

        // Spiritual content (Prières & Chapelets): super = common library,
        // parish = its own content. Both areas can manage.
        Route::resource('prayers', PrayerController::class)->except(['show']);

        // Prayer-intentions wall moderation.
        Route::get('intentions', [PrayerIntentionAdminController::class, 'index'])->name('intentions.index');
        Route::patch('intentions/{intention}/toggle', [PrayerIntentionAdminController::class, 'toggle'])->name('intentions.toggle');
        Route::delete('intentions/{intention}', [PrayerIntentionAdminController::class, 'destroy'])->name('intentions.destroy');

        // Payments (CinetPay) — tracking + mass-intention management.
        Route::get('payments', [PaymentAdminController::class, 'index'])->name('payments.index');
        Route::get('mass-intentions', [MassIntentionController::class, 'index'])->name('mass-intentions.index');
        Route::patch('mass-intentions/{massIntention}/status', [MassIntentionController::class, 'updateStatus'])->name('mass-intentions.status');

        // CinetPay credentials — each parish configures its own merchant account.
        Route::get('payment-settings', [PaymentSettingsController::class, 'edit'])->name('payment-settings.edit');
        Route::put('payment-settings', [PaymentSettingsController::class, 'update'])->name('payment-settings.update');
    });
};

/** Auth (login / logout) routes shared by both areas. */
$authRoutes = function (): void {
    Route::middleware('guest')->group(function () {
        Route::get('login', [LoginController::class, 'show'])->name('login');
        Route::post('login', [LoginController::class, 'login'])->name('login.attempt');
    });

    Route::post('logout', [LoginController::class, 'logout'])->name('logout');
};

// ---- Parish administrator area (/admin) ---------------------------------
Route::prefix('admin')->name('admin.')->group(function () use ($authRoutes, $sharedAdminRoutes) {
    $authRoutes();
    $sharedAdminRoutes('parish');
});

// ---- Movement leader area (/mouvement) ----------------------------------
Route::prefix('mouvement')->name('mouvement.')->group(function () {
    Route::middleware('guest')->group(function () {
        Route::get('login', [\App\Http\Controllers\Movement\AuthController::class, 'show'])->name('login');
        Route::post('login', [\App\Http\Controllers\Movement\AuthController::class, 'login'])->name('login.attempt');
    });
    Route::post('logout', [\App\Http\Controllers\Movement\AuthController::class, 'logout'])->name('logout');

    Route::middleware('movement')->group(function () {
        Route::get('/', [\App\Http\Controllers\Movement\DashboardController::class, 'index'])->name('dashboard');
        Route::resource('posts', \App\Http\Controllers\Movement\PostController::class)->except(['show']);
        Route::get('documents', [\App\Http\Controllers\Movement\DocumentController::class, 'index'])->name('documents.index');
        Route::post('documents', [\App\Http\Controllers\Movement\DocumentController::class, 'store'])->name('documents.store');
        Route::delete('documents/{document}', [\App\Http\Controllers\Movement\DocumentController::class, 'destroy'])->name('documents.destroy');
        Route::get('members', [\App\Http\Controllers\Movement\MemberController::class, 'index'])->name('members.index');
    });
});

// ---- Super administrator area (/super) ----------------------------------
Route::prefix('super')->name('super.')->group(function () use ($authRoutes, $sharedAdminRoutes) {
    $authRoutes();
    $sharedAdminRoutes('super');

    // The parish directory is exclusive to super administrators.
    Route::middleware('admin:super')->group(function () {
        Route::resource('parishes', ParishController::class)->except(['show']);
        Route::patch('parishes/{parish}/toggle', [ParishController::class, 'toggle'])->name('parishes.toggle');

        // The shared liturgy (auto-filled from AELF) is managed by super admins.
        Route::get('liturgies', [LiturgyController::class, 'index'])->name('liturgies.index');
        Route::get('liturgies/{liturgy}/edit', [LiturgyController::class, 'edit'])->name('liturgies.edit');
        Route::put('liturgies/{liturgy}', [LiturgyController::class, 'update'])->name('liturgies.update');
        Route::patch('liturgies/{liturgy}/toggle', [LiturgyController::class, 'toggle'])->name('liturgies.toggle');
        Route::post('liturgies/{liturgy}/resync', [LiturgyController::class, 'resync'])->name('liturgies.resync');
        Route::post('liturgies/sync-upcoming', [LiturgyController::class, 'syncUpcoming'])->name('liturgies.sync-upcoming');

        // Platform-wide settings (Google Maps API key).
        Route::get('settings/google-maps', [\App\Http\Controllers\Admin\PlatformSettingsController::class, 'edit'])->name('settings.google-maps.edit');
        Route::put('settings/google-maps', [\App\Http\Controllers\Admin\PlatformSettingsController::class, 'update'])->name('settings.google-maps.update');

        // Liturgical calendar (major feasts from LitCal).
        Route::get('calendar', [LiturgicalCalendarController::class, 'index'])->name('calendar.index');
        Route::patch('calendar/{event}/toggle', [LiturgicalCalendarController::class, 'toggle'])->name('calendar.toggle');
        Route::post('calendar/resync', [LiturgicalCalendarController::class, 'resync'])->name('calendar.resync');

        // Saint of the day (AELF + Wikipedia FR), auto-filled and editable.
        Route::get('saints', [SaintController::class, 'index'])->name('saints.index');
        Route::get('saints/{saint}/edit', [SaintController::class, 'edit'])->name('saints.edit');
        Route::put('saints/{saint}', [SaintController::class, 'update'])->name('saints.update');
        Route::patch('saints/{saint}/toggle', [SaintController::class, 'toggle'])->name('saints.toggle');
        Route::post('saints/{saint}/resync', [SaintController::class, 'resync'])->name('saints.resync');
        Route::post('saints/sync-upcoming', [SaintController::class, 'syncUpcoming'])->name('saints.sync-upcoming');
    });
});
