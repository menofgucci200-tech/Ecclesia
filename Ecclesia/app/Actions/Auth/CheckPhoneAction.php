<?php

declare(strict_types=1);

namespace App\Actions\Auth;

use App\Repositories\Contracts\UserRepositoryInterface;

class CheckPhoneAction
{
    public function __construct(
        private readonly UserRepositoryInterface $users,
    ) {}

    /**
     * Determine whether an account already exists for the given (normalized) phone number.
     */
    public function execute(string $phone): bool
    {
        return $this->users->existsByPhone($phone);
    }
}
