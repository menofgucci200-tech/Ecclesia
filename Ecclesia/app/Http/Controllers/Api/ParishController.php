<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Parish\IndexParishRequest;
use App\Http\Requests\Parish\SearchParishRequest;
use App\Http\Resources\ParishResource;
use App\Services\ParishService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ParishController extends Controller
{
    public function __construct(
        private readonly ParishService $parishes,
    ) {}

    /**
     * Paginated list of joinable parishes.
     */
    public function index(IndexParishRequest $request): AnonymousResourceCollection
    {
        return ParishResource::collection(
            $this->parishes->paginate(null, $request->perPage()),
        );
    }

    /**
     * Search joinable parishes by name, code, city, commune or region.
     */
    public function search(SearchParishRequest $request): AnonymousResourceCollection
    {
        return ParishResource::collection(
            $this->parishes->paginate($request->term(), $request->perPage()),
        );
    }

    /**
     * Full details of a single joinable parish.
     */
    public function show(int $parish): JsonResponse
    {
        return response()->json([
            'data' => ParishResource::make($this->parishes->findActiveOrFail($parish)),
        ]);
    }
}
