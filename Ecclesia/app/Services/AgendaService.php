<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\LiturgicalEvent;
use App\Models\ParishEvent;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

class AgendaService
{
    public function __construct(
        private readonly LitCalService $litcal,
    ) {}

    /**
     * Upcoming agenda items merging major liturgical feasts and parish events.
     *
     * @return Collection<int, array<string, mixed>>
     */
    public function upcoming(?int $parishId, Carbon $from, Carbon $to): Collection
    {
        // Lazily ensure the liturgical calendar exists for the spanned years.
        for ($y = $from->year; $y <= $to->year; $y++) {
            $this->litcal->ensureYear($y);
        }

        $liturgical = LiturgicalEvent::query()
            ->visible()
            ->whereBetween('date', [$from->toDateString(), $to->toDateString()])
            ->orderBy('date')
            ->get()
            ->map(fn (LiturgicalEvent $e) => [
                'type' => 'liturgical',
                'date' => $e->date->toDateString(),
                'time' => null,
                'title' => $e->name,
                'subtitle' => $e->grade_label,
                'color' => $e->color,
                'grade' => $e->grade,
                'location' => null,
                'description' => null,
                '_sort' => $e->date->toDateString().' 00:00:00',
            ]);

        $parish = collect();
        if ($parishId !== null) {
            $parish = ParishEvent::query()
                ->where('parish_id', $parishId)
                ->where('is_published', true)
                ->whereBetween('starts_at', [$from->copy()->startOfDay(), $to->copy()->endOfDay()])
                ->orderBy('starts_at')
                ->get()
                ->map(fn (ParishEvent $e) => [
                    'type' => 'parish',
                    'date' => $e->starts_at->toDateString(),
                    'time' => $e->starts_at->format('H:i'),
                    'title' => $e->title,
                    'subtitle' => $e->location,
                    'color' => null,
                    'grade' => 0,
                    'location' => $e->location,
                    'description' => $e->description,
                    '_sort' => $e->starts_at->toDateTimeString(),
                ]);
        }

        return $liturgical
            ->concat($parish)
            ->sortBy('_sort')
            ->map(function (array $item) {
                unset($item['_sort']);

                return $item;
            })
            ->values();
    }
}
