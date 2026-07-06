<?php

declare(strict_types=1);

namespace App\Repositories\Contracts;

use App\Models\PasswordResetCode;
use Illuminate\Support\Carbon;

interface PasswordResetCodeRepositoryInterface
{
    public function findByPhone(string $phone): ?PasswordResetCode;

    public function store(string $phone, string $hashedCode, Carbon $expiresAt): PasswordResetCode;

    public function deleteForPhone(string $phone): void;
}
