<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;

class HomeController extends Controller
{
    /**
     * Send visitors to the dashboard matching their role, or to the login page.
     * Invokable (not a closure) so the route table stays cacheable in production.
     */
    public function __invoke(): RedirectResponse
    {
        $user = Auth::user();

        if ($user !== null && $user->isStaff()) {
            return redirect()->route($user->isSuperAdmin() ? 'super.dashboard' : 'admin.dashboard');
        }

        return redirect()->route('admin.login');
    }
}
