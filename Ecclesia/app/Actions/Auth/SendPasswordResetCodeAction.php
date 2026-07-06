<?php

declare(strict_types=1);

namespace App\Actions\Auth;

use App\Mail\PasswordResetCodeMail;
use App\Repositories\Contracts\PasswordResetCodeRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class SendPasswordResetCodeAction
{
    public const CODE_LENGTH = 6;

    public const EXPIRES_IN_MINUTES = 10;

    public function __construct(
        private readonly UserRepositoryInterface $users,
        private readonly PasswordResetCodeRepositoryInterface $codes,
    ) {}

    /**
     * Generate a one-time code, store its hash and e-mail it to the account.
     * Returns the masked destination e-mail for display.
     *
     * @throws ValidationException
     */
    public function execute(string $phone): string
    {
        $user = $this->users->findByPhone($phone);

        if ($user === null) {
            throw ValidationException::withMessages([
                'phone' => 'Aucun compte n\'est associé à ce numéro.',
            ]);
        }

        if ($user->email === null || $user->email === '') {
            throw ValidationException::withMessages([
                'phone' => 'Aucune adresse e-mail n\'est associée à ce compte. Veuillez contacter votre paroisse.',
            ]);
        }

        $code = $this->generateCode();

        $this->codes->store(
            $phone,
            Hash::make($code),
            Carbon::now()->addMinutes(self::EXPIRES_IN_MINUTES),
        );

        Mail::to($user->email)->send(
            new PasswordResetCodeMail($user->first_name, $code, self::EXPIRES_IN_MINUTES),
        );

        return $this->maskEmail($user->email);
    }

    private function generateCode(): string
    {
        $max = (10 ** self::CODE_LENGTH) - 1;

        return str_pad((string) random_int(0, $max), self::CODE_LENGTH, '0', STR_PAD_LEFT);
    }

    private function maskEmail(string $email): string
    {
        [$name, $domain] = explode('@', $email);
        $visible = Str::substr($name, 0, min(2, Str::length($name)));

        return $visible.str_repeat('*', max(1, Str::length($name) - 2)).'@'.$domain;
    }
}
