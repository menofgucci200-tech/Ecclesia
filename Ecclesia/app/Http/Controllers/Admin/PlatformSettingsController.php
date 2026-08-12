<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PlatformSetting;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\View\View;

/**
 * Platform-wide configuration (currently: the Google Maps API key powering
 * "Découvrir" in the app and the address autocomplete on this dashboard).
 * Super-admin only — this isn't per-parish like CinetPay credentials.
 */
class PlatformSettingsController extends Controller implements HasMiddleware
{
    public static function middleware(): array
    {
        return [
            new Middleware(function (Request $request, $next) {
                abort_unless($request->user()?->isSuperAdmin(), 403);

                return $next($request);
            }),
        ];
    }

    public function edit(): View
    {
        return view('admin.settings.google-maps', [
            'hasKey' => filled(PlatformSetting::get(PlatformSetting::GOOGLE_MAPS_API_KEY)),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'google_maps_api_key' => ['nullable', 'string', 'max:255'],
        ]);

        // Blank input keeps the stored key (the form never re-displays it);
        // a dedicated "remove" action would be needed to actually clear it.
        if (filled($validated['google_maps_api_key'] ?? null)) {
            PlatformSetting::set(PlatformSetting::GOOGLE_MAPS_API_KEY, $validated['google_maps_api_key']);
        }

        return back()->with('success', 'Clé Google Maps enregistrée.');
    }
}
