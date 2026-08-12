<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MassIntention;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class MassIntentionController extends Controller
{
    public function index(Request $request): View
    {
        $parishId = $request->user()->managedParishId();
        $status = $request->string('status')->toString();

        $intentions = MassIntention::with(['user', 'payment'])
            ->when($parishId !== null, fn ($q) => $q->where('parish_id', $parishId))
            ->when($status !== '', fn ($q) => $q->where('status', $status))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return view('admin.mass-intentions.index', [
            'intentions' => $intentions,
            'status' => $status,
        ]);
    }

    public function updateStatus(Request $request, MassIntention $massIntention): RedirectResponse
    {
        $parishId = $request->user()->managedParishId();
        abort_unless($parishId === null || $massIntention->parish_id === $parishId, 403);

        $validated = $request->validate([
            'status' => ['required', Rule::in(['paid', 'scheduled', 'celebrated'])],
        ]);

        $massIntention->update(['status' => $validated['status']]);

        return back()->with('success', 'Demande de messe mise à jour.');
    }
}
