<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Parish\AssociateParishRequest;
use App\Http\Resources\ParishResource;
use App\Models\User;
use App\Services\UserParishService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserParishController extends Controller
{
    public function __construct(
        private readonly UserParishService $userParishes,
    ) {}

    /**
     * The parish the authenticated faithful currently belongs to.
     */
    public function show(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $parish = $this->userParishes->current($user);

        return response()->json([
            'data' => $parish !== null ? ParishResource::make($parish) : null,
        ]);
    }

    /**
     * Automatically associate the authenticated faithful to a parish.
     */
    public function store(AssociateParishRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $parish = $this->userParishes->associate($user, $request->parishId());

        return response()->json([
            'success' => true,
            'message' => 'Paroisse associée avec succès.',
            'data' => ParishResource::make($parish),
        ]);
    }
}
