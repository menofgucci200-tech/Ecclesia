<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdmin
{
    /**
     * Allow the request through only for the staff role matching the area.
     *
     * @param  string  $scope  'super' (super admins), 'parish' (parish admins) or 'any'
     */
    public function handle(Request $request, Closure $next, string $scope = 'any'): Response
    {
        $area = $this->area($request);

        /** @var User|null $user */
        $user = $request->user();

        if ($user === null) {
            return redirect()->route($area.'.login');
        }

        $matchesScope = match ($scope) {
            'super' => $user->isSuperAdmin(),
            'parish' => $user->isStaff() && ! $user->isSuperAdmin(),
            default => $user->isStaff(),
        };

        if (! $matchesScope || ! $user->isActive()) {
            $intended = $this->crossAreaMessage($user, $scope);

            Auth::guard('web')->logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return redirect()
                ->route($area.'.login')
                ->withErrors(['email' => $intended]);
        }

        return $next($request);
    }

    /**
     * Derive the area ("super" or "admin") from the current route name.
     */
    private function area(Request $request): string
    {
        $name = $request->route()?->getName() ?? 'admin.';

        return str_starts_with($name, 'super.') ? 'super' : 'admin';
    }

    private function crossAreaMessage(User $user, string $scope): string
    {
        if ($scope === 'super' && $user->isStaff() && ! $user->isSuperAdmin()) {
            return 'Ce compte est un administrateur de paroisse. Connectez-vous depuis l\'espace paroisse (/admin).';
        }

        if ($scope === 'parish' && $user->isSuperAdmin()) {
            return 'Ce compte est un super administrateur. Connectez-vous depuis l\'espace super-admin (/super).';
        }

        return "Ce compte n'a pas accès à cet espace d'administration.";
    }
}
