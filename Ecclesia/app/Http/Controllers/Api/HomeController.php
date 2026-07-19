<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AnnouncementResource;
use App\Http\Resources\LiturgyResource;
use App\Http\Resources\MassTimeResource;
use App\Models\Announcement;
use App\Models\User;
use App\Services\AgendaService;
use App\Services\LiturgyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    public function __construct(
        private readonly LiturgyService $liturgy,
        private readonly AgendaService $agenda,
    ) {}

    /**
     * Aggregated payload for the mobile home screen: the day's liturgy
     * (auto-filled from AELF), the parish mass schedule and the headline
     * announcement. Always returns liturgy even if the parish did nothing.
     */
    public function index(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $user->loadMissing('parish');
        $parish = $user->parish;

        $liturgy = $this->liturgy->visibleForDate(now());

        $massTimes = $parish
            ? $parish->massTimes()->orderBy('day_of_week')->orderBy('time')->get()
            : collect();

        $announcement = null;
        if ($parish !== null) {
            $announcement = Announcement::query()
                ->where('parish_id', $parish->id)
                ->whereNotNull('published_at')
                ->where('published_at', '<=', now())
                ->orderByDesc('is_pinned')
                ->orderByDesc('is_important')
                ->latest('published_at')
                ->first();
        }

        return response()->json([
            'liturgy' => $liturgy ? LiturgyResource::make($liturgy) : null,
            'parish' => $parish === null ? null : [
                'id' => $parish->id,
                'name' => $parish->name,
                'commune' => $parish->commune,
                'logo_url' => $parish->logo ? \Illuminate\Support\Facades\Storage::url($parish->logo) : null,
            ],
            'mass_times' => MassTimeResource::collection($massTimes),
            'next_mass' => $this->nextMass($massTimes),
            'announcement' => $announcement ? AnnouncementResource::make($announcement) : null,
            'events' => $this->agenda->upcoming($parish?->id, now()->startOfDay(), now()->addDays(90))->take(6)->values(),
            'quote' => $this->quoteOfTheDay($liturgy),
        ]);
    }

    /**
     * The next upcoming mass from now, scanning the weekly schedule.
     *
     * @param  \Illuminate\Support\Collection<int, \App\Models\MassTime>  $massTimes
     * @return array<string, mixed>|null
     */
    private function nextMass($massTimes): ?array
    {
        if ($massTimes->isEmpty()) {
            return null;
        }

        $now = now();
        $todayDow = (int) $now->dayOfWeek; // Carbon: 0 = Sunday

        for ($offset = 0; $offset < 7; $offset++) {
            $dow = ($todayDow + $offset) % 7;

            foreach ($massTimes->where('day_of_week', $dow)->sortBy('time') as $mass) {
                [$h, $m] = array_map('intval', explode(':', $mass->formattedTime()));
                $candidate = $now->copy()->addDays($offset)->setTime($h, $m, 0);

                if ($candidate->greaterThan($now)) {
                    return [
                        'day_label' => $mass->dayLabel(),
                        'time' => $mass->formattedTime(),
                        'label' => $mass->label,
                        'at' => $candidate->toIso8601String(),
                    ];
                }
            }
        }

        return null;
    }

    /**
     * A short daily "quote", derived from the gospel reference when available.
     */
    private function quoteOfTheDay(?\App\Models\Liturgy $liturgy): ?array
    {
        $gospel = $liturgy?->gospel();

        if ($gospel === null) {
            return null;
        }

        return [
            'text' => $gospel['title'] ?? null,
            'ref' => $gospel['ref'] ?? null,
        ];
    }
}
