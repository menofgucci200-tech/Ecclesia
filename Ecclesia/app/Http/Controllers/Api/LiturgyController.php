<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\LiturgyResource;
use App\Services\LiturgyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;

class LiturgyController extends Controller
{
    public function __construct(
        private readonly LiturgyService $liturgy,
    ) {}

    /**
     * The liturgy of the current day.
     */
    public function today(): JsonResponse
    {
        return $this->respond(now());
    }

    /**
     * The liturgy of a specific date (YYYY-MM-DD).
     */
    public function show(string $date): JsonResponse
    {
        try {
            $day = Carbon::createFromFormat('Y-m-d', $date)->startOfDay();
        } catch (\Throwable) {
            return response()->json(['message' => 'Date invalide.'], 422);
        }

        return $this->respond($day);
    }

    private function respond(Carbon $date): JsonResponse
    {
        $liturgy = $this->liturgy->visibleForDate($date);

        if ($liturgy === null) {
            return response()->json([
                'liturgy' => null,
                'message' => 'Liturgie indisponible pour cette date.',
            ], 200);
        }

        return response()->json(['liturgy' => LiturgyResource::make($liturgy)]);
    }
}
