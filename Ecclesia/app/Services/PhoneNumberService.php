<?php

declare(strict_types=1);

namespace App\Services;

class PhoneNumberService
{
    /**
     * Default supported country: Côte d'Ivoire.
     */
    public const DEFAULT_COUNTRY_CODE = '225';

    /**
     * Length of a Côte d'Ivoire national number (since the 2021 renumbering).
     */
    private const NATIONAL_LENGTH = 10;

    /**
     * Normalize any user input into a canonical E.164 number (e.g. +2250102030405).
     * Returns null when the input cannot be interpreted as a valid Ivorian number.
     */
    public function normalize(string $raw, string $countryCode = self::DEFAULT_COUNTRY_CODE): ?string
    {
        $national = $this->extractNational($raw, $countryCode);

        if ($national === null) {
            return null;
        }

        return '+'.$countryCode.$national;
    }

    /**
     * Whether the given input is a valid Ivorian mobile number.
     */
    public function isValid(string $raw, string $countryCode = self::DEFAULT_COUNTRY_CODE): bool
    {
        return $this->normalize($raw, $countryCode) !== null;
    }

    /**
     * Extract the national significant number (10 digits, leading zero) from any input.
     */
    private function extractNational(string $raw, string $countryCode): ?string
    {
        $digits = preg_replace('/\D+/', '', $raw) ?? '';

        if ($digits === '') {
            return null;
        }

        // Strip an international "00" prefix.
        if (str_starts_with($digits, '00'.$countryCode)) {
            $digits = substr($digits, 2);
        }

        // Strip the country code if present.
        if (str_starts_with($digits, $countryCode)) {
            $digits = substr($digits, strlen($countryCode));
        }

        if (strlen($digits) !== self::NATIONAL_LENGTH || ! str_starts_with($digits, '0')) {
            return null;
        }

        return $digits;
    }
}
