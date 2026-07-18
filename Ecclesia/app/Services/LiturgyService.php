<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Liturgy;
use Illuminate\Support\Carbon;

class LiturgyService
{
    public function __construct(
        private readonly AelfService $aelf,
    ) {}

    public const DEFAULT_ZONE = 'afrique';

    /**
     * Return the liturgy for a date, fetching it from AELF on first access.
     * Manual edits and hidden days are always respected.
     */
    public function forDate(Carbon $date, string $zone = self::DEFAULT_ZONE): ?Liturgy
    {
        $liturgy = Liturgy::query()
            ->whereDate('date', $date->toDateString())
            ->where('zone', $zone)
            ->first();

        if ($liturgy !== null) {
            return $liturgy;
        }

        return $this->sync($date, $zone);
    }

    /**
     * The liturgy shown in the app for a date (null when hidden by an admin).
     */
    public function visibleForDate(Carbon $date, string $zone = self::DEFAULT_ZONE): ?Liturgy
    {
        $liturgy = $this->forDate($date, $zone);

        return ($liturgy && ! $liturgy->is_hidden) ? $liturgy : null;
    }

    /**
     * Fetch a day from AELF and store it, without overwriting manual edits.
     */
    public function sync(Carbon $date, string $zone = self::DEFAULT_ZONE): ?Liturgy
    {
        $existing = Liturgy::query()
            ->whereDate('date', $date->toDateString())
            ->where('zone', $zone)
            ->first();

        // Never clobber a liturgy an admin has edited by hand.
        if ($existing !== null && $existing->source === 'manual') {
            return $existing;
        }

        $data = $this->aelf->fetchMass($date->toDateString(), $zone);

        if ($data === null) {
            return $existing;
        }

        return Liturgy::query()->updateOrCreate(
            ['date' => $date->toDateString(), 'zone' => $zone],
            [
                ...$data,
                'source' => 'aelf',
                'is_hidden' => $existing->is_hidden ?? false,
                'synced_at' => now(),
            ],
        );
    }
}
