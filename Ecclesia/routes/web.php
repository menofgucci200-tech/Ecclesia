<?php

declare(strict_types=1);

use App\Http\Controllers\Admin\AnnouncementController;
use App\Http\Controllers\Admin\Auth\LoginController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\HomeController;
use App\Http\Controllers\Admin\LiturgyController;
use App\Http\Controllers\Admin\MassTimeController;
use App\Http\Controllers\Admin\MemberController;
use App\Http\Controllers\Admin\ParishController;
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
    });
});
