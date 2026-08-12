<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PrayerResource;
use App\Models\Prayer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Exposes the published spiritual content ("Prières & Chapelets") to the app.
 */
class PrayerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $category = $request->string('category')->toString();

        $prayers = Prayer::query()
            ->published()
            ->visibleTo($request->user()->parish_id)
            ->when($category !== '', fn ($q) => $q->where('category', $category))
            ->ordered()
            ->get();

        return response()->json([
            'prayers' => PrayerResource::collection($prayers),
        ]);
    }
}
