<?php

declare(strict_types=1);

namespace App\Services;

use App\Enums\PaymentStatus;
use App\Models\LiturgicalEvent;
use App\Models\MassIntention;
use App\Models\ParishEvent;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

class AgendaService
{
    public function __construct(
        private readonly LitCalService $litcal,
    ) {}

    /**
     * Upcoming agenda items merging major liturgical feasts, parish events,
     * and — when a faithful is authenticated — their own scheduled mass
     * intentions.
     *
     * @return Collection<int, array<string, mixed>>
     */
    public function upcoming(?int $parishId, Carbon $from, Carbon $to, ?int $userId = null): Collection
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
                ->withCount('rsvps as attendees_count')
                ->when(
                    $userId !== null,
                    fn ($query) => $query->withExists(['rsvps as is_attending' => fn ($q) => $q->where('user_id', $userId)]),
                )
                ->orderBy('starts_at')
                ->get()
                ->map(fn (ParishEvent $e) => [
                    'type' => 'parish',
                    'id' => $e->id,
                    'date' => $e->starts_at->toDateString(),
                    'time' => $e->starts_at->format('H:i'),
                    'title' => $e->title,
                    'subtitle' => $e->location,
                    'color' => null,
                    'grade' => 0,
                    'location' => $e->location,
                    'description' => $e->description,
                    'attendees_count' => $e->attendees_count,
                    'is_attending' => (bool) ($e->is_attending ?? false),
                    '_sort' => $e->starts_at->toDateTimeString(),
                ]);
        }

        $massIntentions = collect();
        if ($userId !== null) {
            $massIntentions = MassIntention::query()
                ->where('user_id', $userId)
                ->whereNotNull('mass_date')
                ->whereBetween('mass_date', [$from->toDateString(), $to->toDateString()])
                ->with('payment')
                ->orderBy('mass_date')
                ->get()
                ->map(fn (MassIntention $mi) => [
                    'type' => 'mass_intention',
                    'date' => $mi->mass_date->toDateString(),
                    'time' => null,
                    'title' => 'Intention : '.$mi->intention_type->label(),
                    'subtitle' => $mi->intention,
                    'color' => null,
                    'grade' => 0,
                    'location' => null,
                    'description' => $mi->intention,
                    'confirmed' => $mi->payment?->status === PaymentStatus::Paid,
                    '_sort' => $mi->mass_date->toDateString().' 00:00:01',
                ]);
        }

        return $liturgical
            ->concat($parish)
            ->concat($massIntentions)
            ->sortBy('_sort')
            ->map(function (array $item) {
                unset($item['_sort']);

                return $item;
            })
            ->values();
    }
}
