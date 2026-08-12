<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PrayerIntention;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

/**
 * Moderation of the community prayer-intentions wall. Parish admins moderate
 * their own parish; super-admins see every parish.
 */
class PrayerIntentionController extends Controller
{
    public function index(Request $request): View
    {
        $parishId = $request->user()->managedParishId();

        $intentions = PrayerIntention::query()
            ->with(['parish', 'author'])
            ->when($parishId !== null, fn ($q) => $q->where('parish_id', $parishId))
            ->latest()
            ->paginate(30);

        return view('admin.intentions.index', compact('intentions'));
    }

    public function toggle(Request $request, PrayerIntention $intention): RedirectResponse
    {
        $this->authorizeParish($request, $intention);
        $intention->update(['is_approved' => ! $intention->is_approved]);

        return back()->with('success', $intention->is_approved ? 'Intention affichée.' : 'Intention masquée.');
    }

    public function destroy(Request $request, PrayerIntention $intention): RedirectResponse
    {
        $this->authorizeParish($request, $intention);
        $intention->delete();

        return back()->with('success', 'Intention supprimée.');
    }

    private function authorizeParish(Request $request, PrayerIntention $intention): void
    {
        $parishId = $request->user()->managedParishId();
        abort_unless($parishId === null || $intention->parish_id === $parishId, 403);
    }
}
