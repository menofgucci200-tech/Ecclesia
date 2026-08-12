<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Enums\PrayerCategory;
use App\Http\Controllers\Controller;
use App\Models\Prayer;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\Enum;
use Illuminate\View\View;

/**
 * CRUD for the "Prières & Chapelets" spiritual content.
 *
 * Scope: super-admins manage the common library (parish_id = null, visible to
 * everyone); parish admins manage their own parish's content (parish_id set).
 */
class PrayerController extends Controller
{
    public function index(Request $request): View
    {
        $parishId = $request->user()->managedParishId();
        $category = $request->string('category')->toString();

        $grouped = Prayer::query()
            ->when($parishId === null, fn ($q) => $q->whereNull('parish_id'), fn ($q) => $q->where('parish_id', $parishId))
            ->when($category !== '', fn ($q) => $q->where('category', $category))
            ->ordered()
            ->get()
            ->groupBy(fn (Prayer $p) => $p->category->value);

        return view('admin.prayers.index', [
            'grouped' => $grouped,
            'categories' => PrayerCategory::cases(),
            'category' => $category,
            'isParish' => $parishId !== null,
        ]);
    }

    public function create(): View
    {
        return view('admin.prayers.create', [
            'prayer' => new Prayer(['category' => PrayerCategory::Priere, 'is_published' => true, 'position' => 0]),
            'categories' => PrayerCategory::cases(),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validated($request);
        $data['parish_id'] = $request->user()->managedParishId();
        $data['image'] = $request->hasFile('image')
            ? $request->file('image')->store('prayers', 'public')
            : null;

        Prayer::create($data);

        return redirect(admin_route('prayers.index'))->with('success', 'Contenu créé.');
    }

    public function edit(Request $request, Prayer $prayer): View
    {
        $this->authorizeOwnership($request, $prayer);

        return view('admin.prayers.edit', [
            'prayer' => $prayer,
            'categories' => PrayerCategory::cases(),
        ]);
    }

    public function update(Request $request, Prayer $prayer): RedirectResponse
    {
        $this->authorizeOwnership($request, $prayer);
        $data = $this->validated($request);

        if ($request->hasFile('image')) {
            if ($prayer->image) {
                Storage::disk('public')->delete($prayer->image);
            }
            $data['image'] = $request->file('image')->store('prayers', 'public');
        }

        $prayer->update($data);

        return redirect(admin_route('prayers.index'))->with('success', 'Contenu mis à jour.');
    }

    public function destroy(Request $request, Prayer $prayer): RedirectResponse
    {
        $this->authorizeOwnership($request, $prayer);

        if ($prayer->image) {
            Storage::disk('public')->delete($prayer->image);
        }
        $prayer->delete();

        return redirect(admin_route('prayers.index'))->with('success', 'Contenu supprimé.');
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        $data = $request->validate([
            'category' => ['required', new Enum(PrayerCategory::class)],
            'title' => ['required', 'string', 'max:255'],
            'subtitle' => ['nullable', 'string', 'max:255'],
            'body' => ['required', 'string'],
            'reference' => ['nullable', 'string', 'max:255'],
            'image' => ['nullable', 'image', 'mimes:jpeg,jpg,png,webp', 'max:4096'],
            'position' => ['nullable', 'integer', 'min:0'],
            'is_published' => ['boolean'],
        ]);
        unset($data['image']); // handled separately (file vs keep-existing)
        $data['is_published'] = $request->boolean('is_published');
        $data['position'] = $data['position'] ?? 0;

        return $data;
    }

    /**
     * A parish admin may only touch its own content; a super-admin only the
     * common (null-parish) library.
     */
    private function authorizeOwnership(Request $request, Prayer $prayer): void
    {
        $parishId = $request->user()->managedParishId();
        abort_unless($prayer->parish_id === $parishId, 403);
    }
}
