<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\SaintResource;
use App\Services\SaintService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;

class SaintController extends Controller
{
    public function __construct(private readonly SaintService $saints)
    {
    }

    public function today(): JsonResponse
    {
        return $this->respond(Carbon::today());
    }

    public function show(string $date): JsonResponse
    {
        return $this->respond(Carbon::parse($date));
    }

    private function respond(Carbon $date): JsonResponse
    {
        $saint = $this->saints->visibleForDate($date);

        return response()->json([
            'saint' => $saint ? new SaintResource($saint) : null,
        ]);
    }
}
