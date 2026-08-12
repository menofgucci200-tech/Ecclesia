<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Parish;
use App\Models\PlatformSetting;
use Illuminate\Support\Facades\Http;

/**
 * Resolves a parish's postal address to coordinates. Uses the Google
 * Geocoding API when a platform API key is configured (super-admin
 * dashboard → Google Maps), falling back to Nominatim (OpenStreetMap's free
 * geocoder — no key, no billing account) otherwise, so geocoding keeps
 * working out of the box before that key is set. Powers the "Découvrir"
 * map: a failed lookup just means the parish doesn't appear on it, so it
 * degrades gracefully rather than blocking a save.
 *
 * @see https://developers.google.com/maps/documentation/geocoding
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

        return $this->geocodeAddress($query);
    }

    /**
     * @return array{lat: float, lng: float}|null
     */
    public function geocodeAddress(string $query): ?array
    {
        $apiKey = PlatformSetting::get(PlatformSetting::GOOGLE_MAPS_API_KEY);

        if (filled($apiKey)) {
            $result = $this->geocodeWithGoogle($query, $apiKey);
            if ($result !== null) {
                return $result;
            }
            // Google failed (quota, transient error…) — Nominatim as a
            // free-tier safety net rather than leaving the parish unlocated.
        }

        return $this->geocodeWithNominatim($query);
    }

    /**
     * @return array{lat: float, lng: float}|null
     */
    private function geocodeWithGoogle(string $query, string $apiKey): ?array
    {
        try {
            $response = Http::timeout(10)->get('https://maps.googleapis.com/maps/api/geocode/json', [
                'address' => $query,
                'key' => $apiKey,
            ]);

            if (! $response->successful() || $response->json('status') !== 'OK') {
                return null;
            }

            $location = $response->json('results.0.geometry.location');
            if (! isset($location['lat'], $location['lng'])) {
                return null;
            }

            return ['lat' => (float) $location['lat'], 'lng' => (float) $location['lng']];
        } catch (\Throwable) {
            return null;
        }
    }

    /**
     * @return array{lat: float, lng: float}|null
     */
    private function geocodeWithNominatim(string $query): ?array
    {
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
