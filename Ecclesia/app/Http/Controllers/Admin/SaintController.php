<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Saint;
use App\Services\SaintService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\View\View;

/**
 * Super-admin management of the "Saint of the day" cache (auto-filled from
 * AELF + Wikipedia FR, editable and hideable).
 */
class SaintController extends Controller
{
    public function __construct(private readonly SaintService $saints)
    {
    }

    public function index(): View
    {
        // Make sure the next two weeks are populated so they can be reviewed.
        $today = Carbon::today();
        for ($i = 0; $i < 14; $i++) {
            $this->saints->forDate($today->copy()->addDays($i));
        }

        $saints = Saint::orderByDesc('date')->paginate(30);

        return view('admin.saints.index', compact('saints'));
    }

    public function edit(Saint $saint): View
    {
        return view('admin.saints.edit', compact('saint'));
    }

    public function update(Request $request, Saint $saint): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['nullable', 'string', 'max:255'],
            'feast' => ['nullable', 'string', 'max:255'],
            'summary' => ['nullable', 'string'],
            'image_url' => ['nullable', 'url', 'max:2000'],
            'wikipedia_url' => ['nullable', 'url', 'max:2000'],
            'is_hidden' => ['boolean'],
        ]);
        $data['is_hidden'] = $request->boolean('is_hidden');
        $data['source'] = 'manual';

        $saint->update($data);

        return redirect()->route('super.saints.index')->with('success', 'Saint du jour mis à jour.');
    }

    public function toggle(Saint $saint): RedirectResponse
    {
        $saint->update(['is_hidden' => ! $saint->is_hidden]);

        return back()->with('success', $saint->is_hidden ? 'Masqué dans l\'application.' : 'De nouveau affiché.');
    }

    public function resync(Saint $saint): RedirectResponse
    {
        $saint->update(['source' => 'aelf']);
        $this->saints->sync(Carbon::parse($saint->date));

        return back()->with('success', 'Resynchronisé depuis AELF + Wikipédia.');
    }

    public function syncUpcoming(): RedirectResponse
    {
        $today = Carbon::today();
        for ($i = 0; $i < 14; $i++) {
            $this->saints->sync($today->copy()->addDays($i));
        }

        return back()->with('success', 'Les deux prochaines semaines ont été synchronisées.');
    }
}
