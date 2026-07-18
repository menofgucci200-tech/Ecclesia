<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Liturgy;
use App\Services\LiturgyService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\Support\Carbon;
use Illuminate\View\View;

class LiturgyController extends Controller implements HasMiddleware
{
    public function __construct(
        private readonly LiturgyService $liturgy,
    ) {}

    /**
     * Managing the shared liturgy is reserved to super admins.
     */
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
        // Make sure today and the next few days exist, then list a window.
        for ($i = 0; $i < 3; $i++) {
            $this->liturgy->forDate(now()->startOfDay()->addDays($i));
        }

        $liturgies = Liturgy::query()
            ->whereDate('date', '>=', now()->subDays(3)->toDateString())
            ->orderBy('date')
            ->limit(30)
            ->get();

        return view('admin.liturgies.index', compact('liturgies'));
    }

    public function edit(Liturgy $liturgy): View
    {
        return view('admin.liturgies.edit', compact('liturgy'));
    }

    public function update(Request $request, Liturgy $liturgy): RedirectResponse
    {
        $validated = $request->validate([
            'liturgical_day' => ['required', 'string', 'max:255'],
            'season' => ['nullable', 'string', 'max:255'],
            'color' => ['nullable', 'string', 'max:50'],
            'week' => ['nullable', 'string', 'max:255'],
            'readings' => ['nullable', 'array'],
            'readings.*.type' => ['required', 'string', 'max:30'],
            'readings.*.ref' => ['nullable', 'string', 'max:255'],
            'readings.*.title' => ['nullable', 'string', 'max:500'],
            'readings.*.content' => ['nullable', 'string'],
        ]);

        $readings = array_values(array_map(static fn (array $r) => [
            'type' => $r['type'],
            'ref' => $r['ref'] ?? '',
            'title' => $r['title'] ?? '',
            'intro' => $r['intro'] ?? '',
            'content' => $r['content'] ?? '',
            'refrain' => $r['refrain'] ?? '',
            'verse' => $r['verse'] ?? '',
        ], $validated['readings'] ?? []));

        $liturgy->update([
            'liturgical_day' => $validated['liturgical_day'],
            'season' => $validated['season'] ?? null,
            'color' => $validated['color'] ?? null,
            'week' => $validated['week'] ?? null,
            'readings' => $readings,
            'source' => 'manual', // protect from the automatic AELF sync
        ]);

        return redirect()
            ->route('super.liturgies.index')
            ->with('success', 'Liturgie du '.$liturgy->date->translatedFormat('d F Y').' mise à jour.');
    }

    /**
     * Toggle whether a day's liturgy is shown in the app.
     */
    public function toggle(Liturgy $liturgy): RedirectResponse
    {
        $liturgy->update(['is_hidden' => ! $liturgy->is_hidden]);

        return back()->with('success', $liturgy->is_hidden ? 'Liturgie masquée dans l\'application.' : 'Liturgie affichée dans l\'application.');
    }

    /**
     * Force a fresh copy from AELF for one day (discards manual edits).
     */
    public function resync(Liturgy $liturgy): RedirectResponse
    {
        $liturgy->update(['source' => 'aelf']); // allow the sync to overwrite
        $fresh = $this->liturgy->sync(Carbon::parse($liturgy->date));

        return back()->with(
            $fresh ? 'success' : 'error',
            $fresh ? 'Liturgie re-synchronisée depuis AELF.' : 'Échec de la synchronisation AELF.'
        );
    }

    /**
     * Fetch the coming week from AELF.
     */
    public function syncUpcoming(): RedirectResponse
    {
        for ($i = 0; $i < 7; $i++) {
            $this->liturgy->sync(now()->startOfDay()->addDays($i));
        }

        return back()->with('success', 'Liturgies de la semaine synchronisées depuis AELF.');
    }
}
