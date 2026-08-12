<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Enums\Gender;
use App\Enums\ParishStatus;
use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\ParishRequest;
use App\Models\Parish;
use App\Models\User;
use App\Services\GeocodingService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class ParishController extends Controller implements HasMiddleware
{
    public function __construct(private readonly GeocodingService $geocoding)
    {
    }

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
            ->with('admin:id,parish_id,username')
            ->orderBy('name')
            ->paginate(12)
            ->withQueryString();

        return view('admin.parishes.index', compact('parishes', 'search', 'status'));
    }

    public function create(): View
    {
        return view('admin.parishes.create', [
            'parish' => new Parish(['status' => ParishStatus::Active, 'subscription_amount' => 2000]),
        ]);
    }

    public function store(ParishRequest $request): RedirectResponse
    {
        $data = $request->validated();
        $login = $data['login'];
        $password = $data['password'];
        unset($data['login'], $data['password']);
        $data = $this->stripBlankSecrets($data);

        $data['logo'] = $request->hasFile('logo')
            ? $request->file('logo')->store('parishes', 'public')
            : null;

        $parish = Parish::create($data);
        // A place picked from the Google autocomplete already carries exact
        // coordinates — no need to re-geocode from the (looser) address text.
        if (! $parish->hasLocation()) {
            $this->geocodeIfNeeded($parish);
        }

        // The parish's administrator account (signs in at /admin with this login).
        User::create([
            'first_name' => 'Administrateur',
            'last_name' => $parish->name,
            'gender' => Gender::Male->value,
            'phone' => null,
            'email' => null,
            'username' => $login,
            'password' => Hash::make($password),
            'parish_id' => $parish->id,
            'parish_joined_at' => now(),
            'status' => UserStatus::Active->value,
            'role' => UserRole::Admin->value,
        ]);

        return redirect()
            ->route('super.parishes.index')
            ->with('success', "La paroisse « {$parish->name} » a été créée. Login administrateur : {$login}");
    }

    public function edit(Parish $parish): View
    {
        $parish->load('admin');

        return view('admin.parishes.edit', compact('parish'));
    }

    public function update(ParishRequest $request, Parish $parish): RedirectResponse
    {
        $data = $request->validated();
        $login = $data['login'] ?? null;
        $password = $data['password'] ?? null;
        unset($data['login'], $data['password']);
        $data = $this->stripBlankSecrets($data);

        if ($request->hasFile('logo')) {
            if ($parish->logo) {
                Storage::disk('public')->delete($parish->logo);
            }
            $data['logo'] = $request->file('logo')->store('parishes', 'public');
        } else {
            unset($data['logo']); // keep the existing logo
        }

        $parish->update($data);

        // A place picked from the Google autocomplete already carries exact
        // coordinates — no need to re-geocode from the (looser) address text.
        if (! $parish->wasChanged(['latitude', 'longitude'])) {
            $this->geocodeIfNeeded($parish, wasAddressChanged: $parish->wasChanged(['address', 'city', 'commune', 'region', 'country']));
        }

        // Create or update the linked administrator account.
        $admin = $parish->admin;
        if ($admin === null && ($login || $password)) {
            $admin = new User([
                'first_name' => 'Administrateur',
                'last_name' => $parish->name,
                'gender' => Gender::Male->value,
                'parish_id' => $parish->id,
                'parish_joined_at' => now(),
                'status' => UserStatus::Active->value,
                'role' => UserRole::Admin->value,
            ]);
        }

        if ($admin !== null) {
            if ($login) {
                $admin->username = $login;
            }
            if ($password) {
                $admin->password = Hash::make($password);
            }
            $admin->save();
        }

        return redirect()
            ->route('super.parishes.index')
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
        if ($parish->members()->where('role', UserRole::Member->value)->exists()) {
            return back()->with('error', "Impossible de supprimer « {$parish->name} » : des fidèles y sont rattachés. Désactivez-la plutôt.");
        }

        if ($parish->logo) {
            Storage::disk('public')->delete($parish->logo);
        }

        // Remove the linked administrator account(s) along with the parish.
        $parish->members()->where('role', UserRole::Admin->value)->delete();

        $name = $parish->name;
        $parish->delete();

        return redirect()
            ->route('super.parishes.index')
            ->with('success', "La paroisse « {$name} » a été supprimée.");
    }

    /**
     * Best-effort geocode for the "Découvrir" map — silently does nothing if
     * the address can't be resolved (e.g. offline, address too vague); the
     * parish just won't appear on the map until a later save succeeds.
     */
    private function geocodeIfNeeded(Parish $parish, bool $wasAddressChanged = true): void
    {
        if (! $wasAddressChanged && $parish->hasLocation()) {
            return;
        }

        $result = $this->geocoding->geocode($parish);
        if ($result !== null) {
            $parish->update(['latitude' => $result['lat'], 'longitude' => $result['lng']]);
        }
    }

    /**
     * Drop blank CinetPay secret fields so an empty input keeps the stored key
     * (the form never re-displays secrets).
     *
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function stripBlankSecrets(array $data): array
    {
        foreach (['cinetpay_api_key', 'cinetpay_secret_key'] as $secret) {
            if (empty($data[$secret])) {
                unset($data[$secret]);
            }
        }

        return $data;
    }
}

