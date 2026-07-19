<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Services\LitCalService;
use Illuminate\Console\Command;

class SyncCalendar extends Command
{
    protected $signature = 'calendar:sync {year? : Année civile (défaut : année courante et suivante)}';

    protected $description = 'Synchronise le calendrier liturgique (fêtes majeures) depuis LitCal';

    public function handle(LitCalService $litcal): int
    {
        $years = $this->argument('year')
            ? [(int) $this->argument('year')]
            : [(int) now()->year, (int) now()->addYear()->year];

        foreach ($years as $year) {
            $count = $litcal->syncYear($year);
            $this->line("<info>✓</info> {$year} — {$count} fêtes majeures synchronisées");
        }

        return self::SUCCESS;
    }
}
