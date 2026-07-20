<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Enums\Gender;
use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Http\Controllers\Controller;
use App\Models\Movement;
use App\Models\Parish;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class MovementController extends Controller
{
    public function index(Request $request): View
    {
        $parish = $this->parish($request);

        $movements = $parish->movements()
            ->withCount('members')
            ->with('admin:id,movement_id,username')
            ->orderBy('name')
            ->get();

        return view('admin.movements.index', compact('parish', 'movements'));
    }

    public function create(Request $request): View
    {
        $this->parish($request);

        return view('admin.movements.create', ['movement' => new Movement(['is_active' => true])]);
    }

    public function store(Request $request): RedirectResponse
    {
        $parish = $this->parish($request);
        $data = $this->validated($request, null);

        $login = $data['login'];
        $password = $data['password'];
        unset($data['login'], $data['password']);

        $data['logo'] = $request->hasFile('logo') ? $request->file('logo')->store('movements', 'public') : null;

        $movement = $parish->movements()->create($data);

        // The movement leader account (signs in at /mouvement).
        User::create([
            'first_name' => 'Responsable',
            'last_name' => $movement->name,
            'gender' => Gender::Male->value,
            'username' => $login,
            'password' => Hash::make($password),
            'parish_id' => $parish->id,
            'movement_id' => $movement->id,
            'status' => UserStatus::Active->value,
            'role' => UserRole::MovementAdmin->value,
        ]);

        return redirect()->route('admin.movements.index')
            ->with('success', "Mouvement « {$movement->name} » créé. Login responsable : {$login}");
    }

    public function edit(Request $request, Movement $movement): View
    {
        $this->authorizeOwnership($request, $movement);
        $movement->load('admin');

        return view('admin.movements.edit', compact('movement'));
    }

    public function update(Request $request, Movement $movement): RedirectResponse
    {
        $this->authorizeOwnership($request, $movement);
        $data = $this->validated($request, $movement);

        $login = $data['login'] ?? null;
        $password = $data['password'] ?? null;
        unset($data['login'], $data['password']);

        if ($request->hasFile('logo')) {
            if ($movement->logo) {
                Storage::disk('public')->delete($movement->logo);
            }
            $data['logo'] = $request->file('logo')->store('movements', 'public');
        } else {
            unset($data['logo']);
        }

        $movement->update($data);

        $admin = $movement->admin;
        if ($admin !== null) {
            if ($login) {
                $admin->username = $login;
            }
            if ($password) {
                $admin->password = Hash::make($password);
            }
            $admin->save();
        }

        return redirect()->route('admin.movements.index')->with('success', "Mouvement « {$movement->name} » mis à jour.");
    }

    public function destroy(Request $request, Movement $movement): RedirectResponse
    {
        $this->authorizeOwnership($request, $movement);

        if ($movement->logo) {
            Storage::disk('public')->delete($movement->logo);
        }
        // Remove the leader account(s) linked to this movement.
        User::where('movement_id', $movement->id)->where('role', UserRole::MovementAdmin->value)->delete();

        $name = $movement->name;
        $movement->delete();

        return redirect()->route('admin.movements.index')->with('success', "Mouvement « {$name} » supprimé.");
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request, ?Movement $movement): array
    {
        $isCreate = $movement === null;
        $adminId = $movement?->admin?->id;

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'category' => ['nullable', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'meeting_info' => ['nullable', 'string', 'max:255'],
            'logo' => ['nullable', 'image', 'mimes:jpeg,jpg,png,webp', 'max:2048'],
            'is_active' => ['boolean'],
            'login' => [
                $isCreate ? 'required' : 'nullable',
                'string', 'min:3', 'max:50', 'regex:/^[A-Za-z0-9@._+\-]+$/',
                Rule::unique('users', 'username')->ignore($adminId),
            ],
            'password' => [$isCreate ? 'required' : 'nullable', 'string', 'min:6', 'max:255'],
        ]);

        $data['is_active'] = $request->boolean('is_active');

        return $data;
    }

    private function parish(Request $request): Parish
    {
        $parishId = $request->user()->managedParishId();
        abort_if($parishId === null, 403, 'Espace réservé aux administrateurs de paroisse.');

        return Parish::findOrFail($parishId);
    }

    private function authorizeOwnership(Request $request, Movement $movement): void
    {
        $parishId = $request->user()->managedParishId();
        abort_unless($parishId !== null && $movement->parish_id === $parishId, 403);
    }
}
