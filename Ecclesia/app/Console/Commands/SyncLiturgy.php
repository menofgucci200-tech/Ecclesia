<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Services\LiturgyService;
use Illuminate\Console\Command;

class SyncLiturgy extends Command
{
    protected $signature = 'liturgy:sync {--days=3 : Nombre de jours à synchroniser à partir d\'aujourd\'hui} {--zone=afrique}';

    protected $description = 'Synchronise la liturgie du jour (et des jours suivants) depuis AELF';

    public function handle(LiturgyService $service): int
    {
        $days = max(1, (int) $this->option('days'));
        $zone = (string) $this->option('zone');

        for ($i = 0; $i < $days; $i++) {
            $date = now()->startOfDay()->addDays($i);
            $liturgy = $service->sync($date, $zone);

            $this->line(($liturgy ? '<info>✓</info>' : '<error>✗</error>')
                .' '.$date->toDateString().' — '.($liturgy?->liturgical_day ?? 'échec de récupération'));
        }

        return self::SUCCESS;
    }
}
