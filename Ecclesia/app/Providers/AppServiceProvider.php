<?php

declare(strict_types=1);

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        $this->configureRateLimiting();
    }

    private function configureRateLimiting(): void
    {
        // Sensitive credential endpoints (check-phone, login) — throttle by phone + IP.
        RateLimiter::for('auth', function (Request $request) {
            $key = (string) ($request->input('phone') ?? $request->ip());

            return [
                Limit::perMinute(10)->by('auth:'.$key),
                Limit::perMinute(30)->by('auth-ip:'.$request->ip()),
            ];
        });

        // Registration — stricter, to slow down abuse.
        RateLimiter::for('register', fn (Request $request) => Limit::perMinute(5)->by('register:'.$request->ip()));

        // General authenticated API traffic.
        RateLimiter::for('api', fn (Request $request) => Limit::perMinute(60)->by(
            $request->user()?->getAuthIdentifier() ?? $request->ip()
        ));
    }
}
