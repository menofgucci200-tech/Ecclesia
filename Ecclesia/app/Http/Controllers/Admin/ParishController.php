<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Enums\ParishStatus;
use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\ParishRequest;
use App\Models\Parish;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\View\View;

class ParishController extends Controller implements HasMiddleware
{
    /**
     * Only super admins manage the parish directory.
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

    public function index(Request $request): View
    {
        $search = trim((string) $request->query('q', ''));
        $status = $request->query('status');

        $parishes = Parish::query()
            ->when($search !== '', fn ($q) => $q->search($search))
            ->when(in_array($status, ParishStatus::values(), true), fn ($q) => $q->where('status', $status))
            ->withCount(['members as members_count' => fn ($q) => $q->where('role', UserRole::Member->value)])
            ->orderBy('name')
            ->paginate(12)
            ->withQueryString();

        return view('admin.parishes.index', compact('parishes', 'search', 'status'));
    }

    public function create(): View
    {
        return view('admin.parishes.create', ['parish' => new Parish(['status' => ParishStatus::Active])]);
    }

    public function store(ParishRequest $request): RedirectResponse
    {
        $parish = Parish::create($request->validated());

        return redirect()
            ->route('admin.parishes.index')
            ->with('success', "La paroisse « {$parish->name} » a été créée.");
    }

    public function edit(Parish $parish): View
    {
        return view('admin.parishes.edit', compact('parish'));
    }

    public function update(ParishRequest $request, Parish $parish): RedirectResponse
    {
        $parish->update($request->validated());

        return redirect()
            ->route('admin.parishes.index')
            ->with('success', "La paroisse « {$parish->name} » a été mise à jour.");
    }

    public function toggle(Parish $parish): RedirectResponse
    {
        $parish->status = $parish->status === ParishStatus::Active
            ? ParishStatus::Inactive
            : ParishStatus::Active;
        $parish->save();

        $state = $parish->status === ParishStatus::Active ? 'activée' : 'désactivée';

        return back()->with('success', "La paroisse « {$parish->name} » a été {$state}.");
    }

    public function destroy(Parish $parish): RedirectResponse
    {
        if ($parish->members()->exists()) {
            return back()->with('error', "Impossible de supprimer « {$parish->name} » : des fidèles y sont rattachés. Désactivez-la plutôt.");
        }

        $name = $parish->name;
        $parish->delete();

        return redirect()
            ->route('admin.parishes.index')
            ->with('success', "La paroisse « {$name} » a été supprimée.");
    }
}
