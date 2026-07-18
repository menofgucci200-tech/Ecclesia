<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Enums\AnnouncementCategory;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\AnnouncementRequest;
use App\Models\Announcement;
use App\Models\Parish;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AnnouncementController extends Controller
{
    public function index(Request $request): View
    {
        /** @var User $admin */
        $admin = $request->user();
        $scopeParishId = $admin->managedParishId();

        $search = trim((string) $request->query('q', ''));
        $category = $request->query('category');

        $announcements = Announcement::query()
            ->with('parish:id,name,commune')
            ->when($scopeParishId !== null, fn ($q) => $q->where('parish_id', $scopeParishId))
            ->when($search !== '', fn ($q) => $q->where('title', 'like', '%'.$search.'%'))
            ->when(in_array($category, AnnouncementCategory::values(), true), fn ($q) => $q->where('category', $category))
            ->orderByDesc('is_pinned')
            ->latest('published_at')
            ->latest('created_at')
            ->paginate(12)
            ->withQueryString();

        return view('admin.announcements.index', [
            'announcements' => $announcements,
            'search' => $search,
            'category' => $category,
            'categories' => AnnouncementCategory::cases(),
        ]);
    }

    public function create(): View
    {
        return view('admin.announcements.create', $this->formData(new Announcement([
            'published_at' => now(),
            'author_name' => auth()->user()->fullName(),
        ])));
    }

    public function store(AnnouncementRequest $request): RedirectResponse
    {
        $data = $this->resolveData($request);

        $announcement = Announcement::create($data);

        return redirect()
            ->route('admin.announcements.index')
            ->with('success', $this->savedMessage($announcement, 'publiée', 'enregistrée en brouillon'));
    }

    public function edit(Announcement $announcement): View
    {
        $this->authorizeScope($announcement);

        return view('admin.announcements.edit', $this->formData($announcement));
    }

    public function update(AnnouncementRequest $request, Announcement $announcement): RedirectResponse
    {
        $this->authorizeScope($announcement);

        $announcement->update($this->resolveData($request, $announcement));

        return redirect()
            ->route('admin.announcements.index')
            ->with('success', "L'annonce « {$announcement->title} » a été mise à jour.");
    }

    public function destroy(Announcement $announcement): RedirectResponse
    {
        $this->authorizeScope($announcement);

        $title = $announcement->title;
        $announcement->delete();

        return redirect()
            ->route('admin.announcements.index')
            ->with('success', "L'annonce « {$title} » a été supprimée.");
    }

    /**
     * Build the validated payload, forcing parish scope and author for parish admins.
     *
     * @return array<string, mixed>
     */
    private function resolveData(AnnouncementRequest $request, ?Announcement $existing = null): array
    {
        /** @var User $admin */
        $admin = $request->user();
        $data = $request->validated();

        $scopeParishId = $admin->managedParishId();
        if ($scopeParishId !== null) {
            $data['parish_id'] = $scopeParishId;
        }

        return $data;
    }

    /**
     * Shared view data for the create/edit forms.
     *
     * @return array<string, mixed>
     */
    private function formData(Announcement $announcement): array
    {
        /** @var User $admin */
        $admin = auth()->user();
        $scopeParishId = $admin->managedParishId();

        return [
            'announcement' => $announcement,
            'categories' => AnnouncementCategory::cases(),
            'parishes' => $scopeParishId === null
                ? Parish::query()->orderBy('name')->get(['id', 'name', 'commune'])
                : collect(),
            'scopeParish' => $scopeParishId !== null ? Parish::find($scopeParishId) : null,
        ];
    }

    /**
     * Parish admins may only touch their own parish's announcements.
     */
    private function authorizeScope(Announcement $announcement): void
    {
        $scopeParishId = auth()->user()->managedParishId();

        if ($scopeParishId !== null) {
            abort_unless($announcement->parish_id === $scopeParishId, 403);
        }
    }

    private function savedMessage(Announcement $a, string $published, string $draft): string
    {
        $isLive = $a->published_at !== null && $a->published_at->lessThanOrEqualTo(now());

        return $isLive
            ? "L'annonce « {$a->title} » a été {$published} — visible dans l'application."
            : "L'annonce « {$a->title} » a été {$draft}.";
    }
}
