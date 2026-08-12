<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;

/**
 * Platform-wide key/value configuration editable from the super-admin
 * dashboard (as opposed to per-parish settings like CinetPay credentials,
 * which live on the Parish model). Values are stored encrypted since the
 * first use case — the Google Maps API key — is a secret.
 */
class PlatformSetting extends Model
{
    protected $fillable = ['key', 'value'];

    protected function casts(): array
    {
        return ['value' => 'encrypted'];
    }

    public const GOOGLE_MAPS_API_KEY = 'google_maps_api_key';

    public static function get(string $key): ?string
    {
        return Cache::rememberForever("platform_setting:{$key}", function () use ($key) {
            return static::where('key', $key)->first()?->value;
        });
    }

    public static function set(string $key, ?string $value): void
    {
        static::updateOrCreate(['key' => $key], ['value' => $value]);
        Cache::forget("platform_setting:{$key}");
    }
}
