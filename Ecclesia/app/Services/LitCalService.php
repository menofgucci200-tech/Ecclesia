<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\LiturgicalEvent;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Fetches the yearly liturgical calendar (major feasts) from the open-source
 * LitCal API and keeps only the celebrations worth showing as "events".
 *
 * @see https://litcal.johnromanodorazio.com
 */
class LitCalService
{
    private const BASE_URL = 'https://litcal.johnromanodorazio.com/api/dev/calendar';

    /** Minimum grade kept: 4 = feast, 5 = feast of the Lord, 6 = solemnity, 7 = highest. */
    private const MIN_GRADE = 4;

    /**
     * Ensure a year is present, fetching it once on first access.
     */
    public function ensureYear(int $year): int
    {
        $count = LiturgicalEvent::query()->where('year', $year)->count();

        if ($count > 0) {
            return $count;
        }

        return $this->syncYear($year);
    }

    /**
     * Fetch a full civil year from LitCal and store the major feasts.
     */
    public function syncYear(int $year): int
    {
        try {
            $response = Http::acceptJson()
                ->timeout(30)
                ->retry(2, 800)
                ->get(self::BASE_URL."/{$year}", ['locale' => 'fr', 'year_type' => 'CIVIL']);
        } catch (\Throwable $e) {
            Log::warning('LitCal fetch failed', ['year' => $year, 'error' => $e->getMessage()]);

            return 0;
        }

        if (! $response->successful()) {
            return 0;
        }

        $stored = 0;

        foreach ($response->json('litcal', []) as $event) {
            if (! $this->keep($event)) {
                continue;
            }

            $date = Carbon::parse($event['date'])->toDateString();
            $name = trim((string) ($event['name'] ?? ''));

            $existing = LiturgicalEvent::query()->where('date', $date)->where('name', $name)->first();
            if ($existing !== null && $existing->source === 'manual') {
                continue; // never clobber a manual edit
            }

            LiturgicalEvent::query()->updateOrCreate(
                ['date' => $date, 'name' => $name],
                [
                    'year' => $year,
                    'grade' => (int) ($event['grade'] ?? 0),
                    'grade_label' => $event['grade_lcl'] ?? null,
                    'color' => is_array($event['color_lcl'] ?? null) ? ($event['color_lcl'][0] ?? null) : ($event['color_lcl'] ?? null),
                    'season' => $event['liturgical_season_lcl'] ?? null,
                    'source' => 'litcal',
                    'synced_at' => now(),
                ],
            );

            $stored++;
        }

        return $stored;
    }

    /**
     * Whether a LitCal celebration is a "major feast" worth listing.
     *
     * @param  array<string, mixed>  $event
     */
    private function keep(array $event): bool
    {
        if ((int) ($event['grade'] ?? 0) < self::MIN_GRADE) {
            return false;
        }

        $name = (string) ($event['name'] ?? '');

        // Drop repetitive Ordinary-Time Sundays and duplicate vigil masses.
        if (stripos($name, 'Temps Ordinaire') !== false) {
            return false;
        }
        if (stripos($name, 'Messe de la Veille') !== false || stripos($name, 'Vigil') !== false) {
            return false;
        }

        return true;
    }
}
