<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ParishEvent;
use App\Models\User;
use App\Services\AgendaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AgendaController extends Controller
{
    public function __construct(
        private readonly AgendaService $agenda,
    ) {}

    /**
     * The full agenda: major liturgical feasts + the parish's own events,
     * from today over the next 12 months.
     */
    public function index(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $parishId = $user->parish_id;

        $from = now()->startOfDay();
        $to = now()->addYear();

        $events = $this->agenda->upcoming($parishId, $from, $to, $user->id);

        return response()->json([
            'events' => $events,
            'count' => $events->count(),
        ]);
    }

    /**
     * Toggles the authenticated faithful's RSVP ("J'y serai") for a parish
     * event. Guarded by the parish's own event (no cross-parish RSVPs).
     */
    public function toggleRsvp(Request $request, ParishEvent $event): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        if ($event->parish_id !== $user->parish_id) {
            abort(403);
        }

        $rsvp = $event->rsvps()->where('user_id', $user->id)->first();

        if ($rsvp !== null) {
            $rsvp->delete();
            $attending = false;
        } else {
            $event->rsvps()->create(['user_id' => $user->id]);
            $attending = true;
        }

        return response()->json([
            'is_attending' => $attending,
            'attendees_count' => $event->rsvps()->count(),
        ]);
    }
}
