<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Models\PasswordResetCode;
use App\Repositories\Contracts\PasswordResetCodeRepositoryInterface;
use Illuminate\Support\Carbon;

class PasswordResetCodeRepository implements PasswordResetCodeRepositoryInterface
{
    public function findByPhone(string $phone): ?PasswordResetCode
    {
        return PasswordResetCode::query()->where('phone', $phone)->first();
    }

    public function store(string $phone, string $hashedCode, Carbon $expiresAt): PasswordResetCode
    {
        return PasswordResetCode::query()->updateOrCreate(
            ['phone' => $phone],
            [
                'code' => $hashedCode,
                'attempts' => 0,
                'expires_at' => $expiresAt,
            ],
        );
    }

    public function deleteForPhone(string $phone): void
    {
        PasswordResetCode::query()->where('phone', $phone)->delete();
    }
}
