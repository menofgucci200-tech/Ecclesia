<?php

declare(strict_types=1);

namespace App\Providers;

use App\Repositories\AnnouncementRepository;
use App\Repositories\Contracts\AnnouncementRepositoryInterface;
use App\Repositories\Contracts\ParishRepositoryInterface;
use App\Repositories\Contracts\PasswordResetCodeRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Repositories\ParishRepository;
use App\Repositories\PasswordResetCodeRepository;
use App\Repositories\UserRepository;
use Illuminate\Contracts\Support\DeferrableProvider;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider implements DeferrableProvider
{
    /**
     * All of the container bindings that should be registered.
     *
     * @var array<class-string, class-string>
     */
    public array $bindings = [
        UserRepositoryInterface::class => UserRepository::class,
        ParishRepositoryInterface::class => ParishRepository::class,
        PasswordResetCodeRepositoryInterface::class => PasswordResetCodeRepository::class,
        AnnouncementRepositoryInterface::class => AnnouncementRepository::class,
    ];

    /**
     * @return array<int, class-string>
     */
    public function provides(): array
    {
        return [
            UserRepositoryInterface::class,
            ParishRepositoryInterface::class,
            PasswordResetCodeRepositoryInterface::class,
            AnnouncementRepositoryInterface::class,
        ];
    }
}
