<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Parish;
use Illuminate\Support\Facades\Http;

/**
 * Resolves a parish's postal address to coordinates via Nominatim
 * (OpenStreetMap's free geocoder) — no API key, no billing account. Powers
 * the "Découvrir" map: parishes without coordinates simply don't appear on
 * it, so a failed lookup degrades gracefully rather than blocking a save.
 *
 * @see https://nominatim.org/release-docs/latest/api/Search/
 */
class GeocodingService
{
    /**
     * Nominatim's usage policy requires a descriptive User-Agent identifying
     * the application (not a generic HTTP client string).
     */
    private const UA = 'EcclesiaApp/1.0 (paroisse; contact@ecclesia.app)';

    /**
     * @return array{lat: float, lng: float}|null
     */
    public function geocode(Parish $parish): ?array
    {
        $query = collect([$parish->address, $parish->commune, $parish->city, $parish->region, $parish->country])
            ->filter(fn (?string $v) => filled($v))
            ->implode(', ');

        if ($query === '') {
            return null;
        }

        try {
            $response = Http::withHeaders(['User-Agent' => self::UA])
                ->timeout(10)
                ->get('https://nominatim.openstreetmap.org/search', [
                    'q' => $query,
                    'format' => 'json',
                    'limit' => 1,
                ]);

            $hit = $response->successful() ? ($response->json()[0] ?? null) : null;

            if ($hit === null || ! isset($hit['lat'], $hit['lon'])) {
                return null;
            }

            return ['lat' => (float) $hit['lat'], 'lng' => (float) $hit['lon']];
        } catch (\Throwable) {
            return null;
        }
    }
}
