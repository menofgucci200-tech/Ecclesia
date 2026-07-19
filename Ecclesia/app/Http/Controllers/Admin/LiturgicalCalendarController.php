<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\LiturgicalEvent;
use App\Services\LitCalService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\View\View;

class LiturgicalCalendarController extends Controller implements HasMiddleware
{
    public function __construct(
        private readonly LitCalService $litcal,
    ) {}

    public static function middleware(): array
    {
        return [
            new Middleware(function (Request $request, $next) {
                abort_unless($request->user()?->isSuperAdmin(), 403);

                return $next($request);
            }),
        ];
    }

    public function index(): View
    {
        $this->litcal->ensureYear((int) now()->year);

        $events = LiturgicalEvent::query()
            ->whereDate('date', '>=', now()->subMonth()->toDateString())
            ->orderBy('date')
            ->limit(60)
            ->get();

        return view('admin.calendar.index', compact('events'));
    }

    public function toggle(LiturgicalEvent $event): RedirectResponse
    {
        $event->update(['is_hidden' => ! $event->is_hidden]);

        return back()->with('success', $event->is_hidden ? 'Fête masquée dans l\'application.' : 'Fête affichée dans l\'application.');
    }

    public function resync(): RedirectResponse
    {
        $a = $this->litcal->syncYear((int) now()->year);
        $b = $this->litcal->syncYear((int) now()->addYear()->year);

        return back()->with('success', "Calendrier re-synchronisé depuis LitCal (".($a + $b)." fêtes).");
    }
}
