<?php

declare(strict_types=1);

namespace App\Actions\Auth;

use App\DataTransferObjects\AuthResult;
use App\Exceptions\AccountInactiveException;
use App\Exceptions\InvalidCredentialsException;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Services\TokenService;
use Illuminate\Support\Facades\Hash;

class LoginUserAction
{
    public function __construct(
        private readonly UserRepositoryInterface $users,
        private readonly TokenService $tokens,
    ) {}

    /**
     * @throws InvalidCredentialsException
     * @throws AccountInactiveException
     */
    public function execute(string $phone, string $password, ?string $deviceName = null): AuthResult
    {
        $user = $this->users->findByPhone($phone);

        if ($user === null || ! Hash::check($password, $user->password)) {
            throw new InvalidCredentialsException;
        }

        if (! $user->isActive()) {
            throw new AccountInactiveException;
        }

        $token = $this->tokens->issue($user, $deviceName);

        return new AuthResult($user, $token);
    }
}
