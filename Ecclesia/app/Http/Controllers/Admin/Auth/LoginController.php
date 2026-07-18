<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class LoginController extends Controller
{
    /**
     * Show the administration login form for the current area.
     */
    public function show(Request $request): View|RedirectResponse
    {
        $area = $this->area($request);

        if (Auth::check() && Auth::user()->isStaff()) {
            return redirect()->route($this->areaFor(Auth::user()).'.dashboard');
        }

        return view('admin.auth.login', [
            'area' => $area,
            'isSuper' => $area === 'super',
        ]);
    }

    /**
     * Attempt to authenticate a staff member into the matching area.
     */
    public function login(Request $request): RedirectResponse
    {
        $area = $this->area($request);

        $request->validate([
            'email' => ['required', 'string'],
            'password' => ['required', 'string'],
        ]);

        // The field accepts either an e-mail (super admins) or a login/username
        // (parish admins). Resolve which column to authenticate against.
        $identifier = (string) $request->input('email');
        $field = filter_var($identifier, FILTER_VALIDATE_EMAIL) ? 'email' : 'username';

        $credentials = [$field => $identifier, 'password' => $request->input('password')];

        if (! Auth::attempt($credentials, $request->boolean('remember'))) {
            throw ValidationException::withMessages([
                'email' => 'Ces identifiants ne correspondent à aucun compte.',
            ]);
        }

        /** @var User $user */
        $user = Auth::user();

        $allowed = $area === 'super'
            ? $user->isSuperAdmin()
            : $user->isStaff() && ! $user->isSuperAdmin();

        if (! $allowed || ! $user->isActive()) {
            $message = $this->rejectionMessage($area, $user);

            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            throw ValidationException::withMessages(['email' => $message]);
        }

        $request->session()->regenerate();

        return redirect()->intended(route($area.'.dashboard'));
    }

    /**
     * Log the current staff member out, back to their area's login.
     */
    public function logout(Request $request): RedirectResponse
    {
        $area = $this->area($request);

        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route($area.'.login');
    }

    /**
     * The area of the current route ("super" or "admin").
     */
    private function area(Request $request): string
    {
        $name = $request->route()?->getName() ?? Route::currentRouteName() ?? 'admin.';

        return str_starts_with((string) $name, 'super.') ? 'super' : 'admin';
    }

    private function areaFor(User $user): string
    {
        return $user->isSuperAdmin() ? 'super' : 'admin';
    }

    private function rejectionMessage(string $area, User $user): string
    {
        if ($area === 'super' && $user->isStaff() && ! $user->isSuperAdmin()) {
            return 'Ce compte est un administrateur de paroisse. Utilisez plutôt l\'espace paroisse.';
        }

        if ($area === 'admin' && $user->isSuperAdmin()) {
            return 'Ce compte est un super administrateur. Utilisez plutôt l\'espace super-admin.';
        }

        return "Ce compte n'a pas accès à cet espace d'administration.";
    }
}
