<?php

declare(strict_types=1);

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Fetches the daily liturgy from the official AELF API
 * (Association Épiscopale Liturgique pour les pays Francophones).
 *
 * @see https://api.aelf.org
 */
class AelfService
{
    private const BASE_URL = 'https://api.aelf.org/v1';

    /**
     * Fetch and normalise the mass of a given day, or null on failure.
     *
     * @return array{liturgical_day: string, season: ?string, color: ?string, week: ?string, readings: list<array<string,mixed>>}|null
     */
    public function fetchMass(string $date, string $zone = 'afrique'): ?array
    {
        try {
            $response = Http::acceptJson()
                ->timeout(20)
                ->retry(2, 500)
                ->get(self::BASE_URL."/messes/{$date}/{$zone}");
        } catch (\Throwable $e) {
            Log::warning('AELF fetch failed', ['date' => $date, 'zone' => $zone, 'error' => $e->getMessage()]);

            return null;
        }

        if (! $response->successful()) {
            return null;
        }

        $data = $response->json();
        $info = $data['informations'] ?? [];
        $lectures = $data['messes'][0]['lectures'] ?? [];

        return [
            'liturgical_day' => (string) ($info['jour_liturgique_nom'] ?? 'Liturgie du jour'),
            'season' => $info['temps_liturgique'] ?? null,
            'color' => $info['couleur'] ?? null,
            'week' => $info['semaine'] ?? null,
            'readings' => $this->normaliseReadings($lectures),
        ];
    }

    /**
     * @param  array<int, array<string, mixed>>  $lectures
     * @return list<array<string, mixed>>
     */
    private function normaliseReadings(array $lectures): array
    {
        $readings = [];

        foreach ($lectures as $lecture) {
            $type = $lecture['type'] ?? null;
            if ($type === null) {
                continue;
            }

            $readings[] = [
                'type' => $type,                                   // lecture_1 | psaume | lecture_2 | evangile | …
                'ref' => $this->clean($lecture['ref'] ?? ''),
                'title' => $this->clean($lecture['titre'] ?? ''),
                'intro' => $this->clean($lecture['intro_lue'] ?? ''),
                'content' => $lecture['contenu'] ?? '',            // HTML, kept as-is for rich display
                'refrain' => $lecture['refrain_psalmique'] ?? '',
                'verse' => $lecture['verset_evangile'] ?? '',
            ];
        }

        return $readings;
    }

    private function clean(?string $value): string
    {
        return trim(html_entity_decode(strip_tags((string) $value)));
    }
}
