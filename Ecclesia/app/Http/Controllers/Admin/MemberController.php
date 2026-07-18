<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Http\Controllers\Controller;
use App\Models\Parish;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class MemberController extends Controller
{
    public function index(Request $request): View
    {
        /** @var User $admin */
        $admin = $request->user();
        $scopeParishId = $admin->managedParishId();

        $search = trim((string) $request->query('q', ''));
        $status = $request->query('status');
        $parishFilter = $request->query('parish');

        $members = User::query()
            ->where('role', UserRole::Member->value)
            ->with('parish:id,name,commune')
            ->when($scopeParishId !== null, fn ($q) => $q->where('parish_id', $scopeParishId))
            ->when($parishFilter && $scopeParishId === null, fn ($q) => $q->where('parish_id', $parishFilter))
            ->when($search !== '', function ($q) use ($search) {
                $like = '%'.$search.'%';
                $q->where(fn ($sub) => $sub
                    ->where('first_name', 'like', $like)
                    ->orWhere('last_name', 'like', $like)
                    ->orWhere('phone', 'like', $like)
                    ->orWhere('email', 'like', $like));
            })
            ->when(in_array($status, UserStatus::values(), true), fn ($q) => $q->where('status', $status))
            ->latest('created_at')
            ->paginate(15)
            ->withQueryString();

        $parishes = $scopeParishId === null
            ? Parish::query()->orderBy('name')->get(['id', 'name'])
            : collect();

        return view('admin.members.index', compact('members', 'search', 'status', 'parishFilter', 'parishes', 'scopeParishId'));
    }

    public function show(User $member): View
    {
        $this->authorizeScope($member);

        abort_unless($member->role === UserRole::Member, 404);

        $member->load('parish');

        return view('admin.members.show', compact('member'));
    }

    public function updateStatus(Request $request, User $member): RedirectResponse
    {
        $this->authorizeScope($member);
        abort_unless($member->role === UserRole::Member, 404);

        $validated = $request->validate([
            'status' => ['required', Rule::in(UserStatus::values())],
        ]);

        $member->update(['status' => $validated['status']]);

        return back()->with('success', "Le statut de {$member->fullName()} a été mis à jour.");
    }

    /**
     * Parish admins may only act on members of their own parish.
     */
    private function authorizeScope(User $member): void
    {
        $scopeParishId = auth()->user()->managedParishId();

        if ($scopeParishId !== null) {
            abort_unless($member->parish_id === $scopeParishId, 403);
        }
    }
}
