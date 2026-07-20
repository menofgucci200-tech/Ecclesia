<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureMovementAdmin
{
    /**
     * Allow the request through only for an active movement leader.
     */
    public function handle(Request $request, Closure $next): Response
    {
        /** @var User|null $user */
        $user = $request->user();

        if ($user === null) {
            return redirect()->route('mouvement.login');
        }

        if (! $user->isMovementAdmin() || ! $user->isActive() || $user->movement_id === null) {
            Auth::guard('web')->logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return redirect()->route('mouvement.login')
                ->withErrors(['email' => "Ce compte n'a pas accès à l'espace mouvement."]);
        }

        return $next($request);
    }
}
