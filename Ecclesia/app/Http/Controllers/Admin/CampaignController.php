<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Campaign;
use App\Models\Parish;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class CampaignController extends Controller
{
    public function index(Request $request): View
    {
        $parish = $this->parish($request);
        $campaigns = $parish->campaigns()->latest()->paginate(12);

        return view('admin.campaigns.index', compact('parish', 'campaigns'));
    }

    public function create(Request $request): View
    {
        $this->parish($request);

        return view('admin.campaigns.create', ['campaign' => new Campaign(['type' => 'don', 'is_active' => true])]);
    }

    public function store(Request $request): RedirectResponse
    {
        $parish = $this->parish($request);
        $data = $this->validated($request);
        $data['image'] = $request->hasFile('image') ? $request->file('image')->store('campaigns', 'public') : null;

        $parish->campaigns()->create($data);

        return redirect()->route('admin.campaigns.index')->with('success', 'Collecte créée.');
    }

    public function edit(Request $request, Campaign $campaign): View
    {
        $this->authorizeOwnership($request, $campaign);

        return view('admin.campaigns.edit', compact('campaign'));
    }

    public function update(Request $request, Campaign $campaign): RedirectResponse
    {
        $this->authorizeOwnership($request, $campaign);
        $data = $this->validated($request);

        if ($request->hasFile('image')) {
            if ($campaign->image) {
                Storage::disk('public')->delete($campaign->image);
            }
            $data['image'] = $request->file('image')->store('campaigns', 'public');
        }

        $campaign->update($data);

        return redirect()->route('admin.campaigns.index')->with('success', 'Collecte mise à jour.');
    }

    public function destroy(Request $request, Campaign $campaign): RedirectResponse
    {
        $this->authorizeOwnership($request, $campaign);
        if ($campaign->image) {
            Storage::disk('public')->delete($campaign->image);
        }
        $campaign->delete();

        return redirect()->route('admin.campaigns.index')->with('success', 'Collecte supprimée.');
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'type' => ['required', Rule::in(['don', 'cotisation', 'quete'])],
            'target_amount' => ['nullable', 'integer', 'min:0'],
            'collected_amount' => ['nullable', 'integer', 'min:0'],
            'image' => ['nullable', 'image', 'mimes:jpeg,jpg,png,webp', 'max:2048'],
            'is_active' => ['boolean'],
            'ends_at' => ['nullable', 'date'],
        ]);
        $data['is_active'] = $request->boolean('is_active');
        $data['collected_amount'] = $data['collected_amount'] ?? 0;

        return $data;
    }

    private function parish(Request $request): Parish
    {
        $parishId = $request->user()->managedParishId();
        abort_if($parishId === null, 403, 'Espace réservé aux administrateurs de paroisse.');

        return Parish::findOrFail($parishId);
    }

    private function authorizeOwnership(Request $request, Campaign $campaign): void
    {
        $parishId = $request->user()->managedParishId();
        abort_unless($parishId !== null && $campaign->parish_id === $parishId, 403);
    }
}
