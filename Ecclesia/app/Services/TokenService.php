<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\User;

class TokenService
{
    public const DEFAULT_DEVICE_NAME = 'ecclesia-mobile';

    /**
     * Issue a fresh personal access token for the given user/device.
     */
    public function issue(User $user, ?string $deviceName = null): string
    {
        return $user->createToken($this->sanitizeDeviceName($deviceName))->plainTextToken;
    }

    /**
     * Revoke the token currently used to authenticate the request.
     */
    public function revokeCurrent(User $user): void
    {
        $token = $user->currentAccessToken();

        if ($token !== null && method_exists($token, 'delete')) {
            $token->delete();
        }
    }

    private function sanitizeDeviceName(?string $deviceName): string
    {
        $deviceName = trim((string) $deviceName);

        return $deviceName !== '' ? mb_substr($deviceName, 0, 255) : self::DEFAULT_DEVICE_NAME;
    }
}
