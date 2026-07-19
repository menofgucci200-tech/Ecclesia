<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Parish;
use App\Models\ParishEvent;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class ParishEventController extends Controller
{
    public function index(Request $request): View
    {
        $parish = $this->parish($request);

        $events = $parish->events()->orderByDesc('starts_at')->paginate(15);

        return view('admin.events.index', compact('parish', 'events'));
    }

    public function create(Request $request): View
    {
        $this->parish($request);

        return view('admin.events.create', ['event' => new ParishEvent(['is_published' => true])]);
    }

    public function store(Request $request): RedirectResponse
    {
        $parish = $this->parish($request);
        $data = $this->validated($request);

        $data['image'] = $request->hasFile('image')
            ? $request->file('image')->store('events', 'public')
            : null;

        $parish->events()->create($data);

        return redirect()->route('admin.events.index')->with('success', 'Événement créé.');
    }

    public function edit(Request $request, ParishEvent $event): View
    {
        $this->authorizeOwnership($request, $event);

        return view('admin.events.edit', compact('event'));
    }

    public function update(Request $request, ParishEvent $event): RedirectResponse
    {
        $this->authorizeOwnership($request, $event);

        $data = $this->validated($request);

        if ($request->hasFile('image')) {
            if ($event->image) {
                Storage::disk('public')->delete($event->image);
            }
            $data['image'] = $request->file('image')->store('events', 'public');
        }

        $event->update($data);

        return redirect()->route('admin.events.index')->with('success', 'Événement mis à jour.');
    }

    public function destroy(Request $request, ParishEvent $event): RedirectResponse
    {
        $this->authorizeOwnership($request, $event);

        if ($event->image) {
            Storage::disk('public')->delete($event->image);
        }
        $event->delete();

        return redirect()->route('admin.events.index')->with('success', 'Événement supprimé.');
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        return $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'starts_at' => ['required', 'date'],
            'ends_at' => ['nullable', 'date', 'after_or_equal:starts_at'],
            'location' => ['nullable', 'string', 'max:255'],
            'image' => ['nullable', 'image', 'mimes:jpeg,jpg,png,webp', 'max:2048'],
            'is_published' => ['boolean'],
        ]) + ['is_published' => $request->boolean('is_published')];
    }

    private function parish(Request $request): Parish
    {
        $parishId = $request->user()->managedParishId();
        abort_if($parishId === null, 403, 'Espace réservé aux administrateurs de paroisse.');

        return Parish::findOrFail($parishId);
    }

    private function authorizeOwnership(Request $request, ParishEvent $event): void
    {
        $parishId = $request->user()->managedParishId();
        abort_unless($parishId !== null && $event->parish_id === $parishId, 403);
    }
}
