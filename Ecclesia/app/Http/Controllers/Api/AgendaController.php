<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
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

        $events = $this->agenda->upcoming($parishId, $from, $to);

        return response()->json([
            'events' => $events,
            'count' => $events->count(),
        ]);
    }
}
