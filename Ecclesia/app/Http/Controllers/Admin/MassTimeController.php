<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MassTime;
use App\Models\Parish;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class MassTimeController extends Controller
{
    public function index(Request $request): View
    {
        $parish = $this->parish($request);

        $massTimes = $parish->massTimes()->orderBy('day_of_week')->orderBy('time')->get();

        return view('admin.mass-times.index', compact('parish', 'massTimes'));
    }

    public function store(Request $request): RedirectResponse
    {
        $parish = $this->parish($request);

        $data = $this->validated($request);
        $parish->massTimes()->create($data);

        return back()->with('success', 'Horaire de messe ajouté.');
    }

    public function update(Request $request, MassTime $massTime): RedirectResponse
    {
        $this->authorizeOwnership($request, $massTime);

        $massTime->update($this->validated($request));

        return back()->with('success', 'Horaire de messe mis à jour.');
    }

    public function destroy(Request $request, MassTime $massTime): RedirectResponse
    {
        $this->authorizeOwnership($request, $massTime);

        $massTime->delete();

        return back()->with('success', 'Horaire de messe supprimé.');
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        return $request->validate([
            'day_of_week' => ['required', 'integer', 'between:0,6'],
            'time' => ['required', 'date_format:H:i'],
            'label' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string', 'max:255'],
        ]);
    }

    /**
     * The parish the current admin manages (parish admins only).
     */
    private function parish(Request $request): Parish
    {
        $parishId = $request->user()->managedParishId();
        abort_if($parishId === null, 403, 'Cet espace est réservé aux administrateurs de paroisse.');

        return Parish::findOrFail($parishId);
    }

    private function authorizeOwnership(Request $request, MassTime $massTime): void
    {
        $parishId = $request->user()->managedParishId();
        abort_unless($parishId !== null && $massTime->parish_id === $parishId, 403);
    }
}
