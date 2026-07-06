<?php

declare(strict_types=1);

namespace App\Actions\Auth;

use App\DataTransferObjects\AuthResult;
use App\Repositories\Contracts\PasswordResetCodeRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Services\TokenService;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class ResetPasswordAction
{
    public const MAX_ATTEMPTS = 5;

    public function __construct(
        private readonly UserRepositoryInterface $users,
        private readonly PasswordResetCodeRepositoryInterface $codes,
        private readonly TokenService $tokens,
    ) {}

    /**
     * Verify the reset code, update the password and open a fresh session.
     *
     * @throws ValidationException
     */
    public function execute(string $phone, string $code, string $newPassword, ?string $deviceName = null): AuthResult
    {
        $record = $this->codes->findByPhone($phone);

        if ($record === null) {
            $this->fail('Aucune demande de réinitialisation en cours. Veuillez demander un nouveau code.');
        }

        if ($record->isExpired()) {
            $this->codes->deleteForPhone($phone);
            $this->fail('Le code a expiré. Veuillez demander un nouveau code.');
        }

        if ($record->hasReachedMaxAttempts(self::MAX_ATTEMPTS)) {
            $this->codes->deleteForPhone($phone);
            $this->fail('Trop de tentatives. Veuillez demander un nouveau code.');
        }

        if (! Hash::check($code, $record->code)) {
            $record->markAttempt();
            $this->fail('Code incorrect.');
        }

        $user = $this->users->findByPhone($phone);

        if ($user === null) {
            $this->fail('Aucun compte n\'est associé à ce numéro.');
        }

        $user = $this->users->update($user, ['password' => $newPassword]);
        $this->codes->deleteForPhone($phone);

        $token = $this->tokens->issue($user, $deviceName);

        return new AuthResult($user, $token);
    }

    /**
     * @throws ValidationException
     */
    private function fail(string $message): never
    {
        throw ValidationException::withMessages(['code' => $message]);
    }
}
