<?php

declare(strict_types=1);

namespace App\Http\Requests\Concerns;

use App\Services\PhoneNumberService;

/**
 * Normalizes the "phone" input to a canonical E.164 form before validation,
 * so uniqueness checks and lookups always operate on the stored format.
 */
trait NormalizesPhone
{
    protected function normalizePhoneInput(): void
    {
        $raw = $this->input('phone');

        if (! is_string($raw) || $raw === '') {
            return;
        }

        $normalized = app(PhoneNumberService::class)->normalize($raw);

        if ($normalized !== null) {
            $this->merge(['phone' => $normalized]);
        }
    }
}
