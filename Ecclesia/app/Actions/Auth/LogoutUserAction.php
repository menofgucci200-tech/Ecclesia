<?php

declare(strict_types=1);

namespace App\Actions\Auth;

use App\Models\User;
use App\Services\TokenService;

class LogoutUserAction
{
    public function __construct(
        private readonly TokenService $tokens,
    ) {}

    /**
     * Revoke the access token that authenticated the current request.
     */
    public function execute(User $user): void
    {
        $this->tokens->revokeCurrent($user);
    }
}
