<?php

declare(strict_types=1);

namespace App\Actions\Auth;

use App\DataTransferObjects\AuthResult;
use App\DataTransferObjects\RegisterData;
use App\Enums\UserStatus;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Services\TokenService;
use Illuminate\Support\Facades\DB;

class RegisterUserAction
{
    public function __construct(
        private readonly UserRepositoryInterface $users,
        private readonly TokenService $tokens,
    ) {}

    public function execute(RegisterData $data, ?string $deviceName = null): AuthResult
    {
        $user = DB::transaction(function () use ($data) {
            return $this->users->create([
                ...$data->toAttributes(),
                'status' => UserStatus::Active->value,
            ]);
        });

        $token = $this->tokens->issue($user, $deviceName);

        return new AuthResult($user, $token);
    }
}
