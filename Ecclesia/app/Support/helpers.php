<?php

declare(strict_types=1);

use Illuminate\Support\Facades\Auth;

if (! function_exists('admin_area')) {
    /**
     * The route-name / URL prefix of the current administrator's area.
     * Super administrators live under "super", parish admins under "admin".
     */
    function admin_area(): string
    {
        return Auth::check() && Auth::user()->isSuperAdmin() ? 'super' : 'admin';
    }
}

if (! function_exists('admin_route')) {
    /**
     * Generate a URL for a dashboard route, scoped to the current area.
     *
     * @param  array<string, mixed>|mixed  $parameters
     */
    function admin_route(string $name, mixed $parameters = [], bool $absolute = true): string
    {
        return route(admin_area().'.'.$name, $parameters, $absolute);
    }
}

if (! function_exists('admin_route_is')) {
    /**
     * Whether the current route matches the given pattern within the active area.
     */
    function admin_route_is(string $pattern): bool
    {
        return request()->routeIs(admin_area().'.'.$pattern);
    }
}
