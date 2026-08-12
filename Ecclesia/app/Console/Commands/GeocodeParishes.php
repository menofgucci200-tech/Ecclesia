<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Models\Parish;
use App\Services\GeocodingService;
use Illuminate\Console\Command;

/**
 * Backfills coordinates for parishes that don't have any yet (existing data,
 * or a Nominatim lookup that failed at save time). Sleeps 1s between calls
 * to respect Nominatim's free-tier rate limit (max 1 request/second).
 */
class GeocodeParishes extends Command
{
    protected $signature = 'app:geocode-parishes {--all : Re-geocode every parish, even those that already have coordinates}';

    protected $description = 'Geocode parish addresses to coordinates via Nominatim, for the "Découvrir" map';

    public function handle(GeocodingService $geocoding): int
    {
        $parishes = Parish::query()
            ->when(! $this->option('all'), fn ($q) => $q->whereNull('latitude')->orWhereNull('longitude'))
            ->get();

        if ($parishes->isEmpty()) {
            $this->info('Aucune paroisse à géocoder.');

            return self::SUCCESS;
        }

        $this->info("Géocodage de {$parishes->count()} paroisse(s)…");
        $ok = 0;
        $failed = 0;

        foreach ($parishes as $i => $parish) {
            $result = $geocoding->geocode($parish);

            if ($result === null) {
                $failed++;
                $this->warn("  ✗ {$parish->name} — adresse introuvable");
            } else {
                $parish->update(['latitude' => $result['lat'], 'longitude' => $result['lng']]);
                $ok++;
                $this->line("  ✓ {$parish->name} — {$result['lat']}, {$result['lng']}");
            }

            if ($i < $parishes->count() - 1) {
                sleep(1); // Nominatim's usage policy: max 1 request/second.
            }
        }

        $this->info("Terminé : {$ok} géocodée(s), {$failed} échec(s).");

        return self::SUCCESS;
    }
}
