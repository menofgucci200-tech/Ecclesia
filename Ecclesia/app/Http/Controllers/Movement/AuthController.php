<?php

declare(strict_types=1);

namespace App\Http\Controllers\Movement;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class AuthController extends Controller
{
    public function show(): View|RedirectResponse
    {
        if (Auth::check() && Auth::user()->isMovementAdmin()) {
            return redirect()->route('mouvement.dashboard');
        }

        return view('movement.auth.login');
    }

    public function login(Request $request): RedirectResponse
    {
        $request->validate([
            'email' => ['required', 'string'],
            'password' => ['required', 'string'],
        ]);

        $identifier = (string) $request->input('email');
        $password = $request->input('password');
        $remember = $request->boolean('remember');

        $ok = Auth::attempt(['username' => $identifier, 'password' => $password], $remember)
            || Auth::attempt(['email' => $identifier, 'password' => $password], $remember);

        if (! $ok) {
            throw ValidationException::withMessages(['email' => 'Ces identifiants ne correspondent à aucun compte.']);
        }

        /** @var User $user */
        $user = Auth::user();

        if (! $user->isMovementAdmin() || ! $user->isActive()) {
            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            throw ValidationException::withMessages(['email' => "Ce compte n'a pas accès à l'espace mouvement."]);
        }

        $request->session()->regenerate();

        return redirect()->intended(route('mouvement.dashboard'));
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('mouvement.login');
    }
}
