<?php

declare(strict_types=1);

namespace App\Rules;

use App\Services\PhoneNumberService;
use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class IvorianPhoneNumber implements ValidationRule
{
    public function __construct(
        private readonly PhoneNumberService $phoneNumbers,
    ) {}

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (! is_string($value) || ! $this->phoneNumbers->isValid($value)) {
            $fail('Le numéro de téléphone n\'est pas valide.');
        }
    }
}
