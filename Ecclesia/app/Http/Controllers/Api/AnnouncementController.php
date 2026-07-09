<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Announcement\IndexAnnouncementRequest;
use App\Http\Resources\AnnouncementResource;
use App\Models\User;
use App\Services\AnnouncementService;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class AnnouncementController extends Controller
{
    public function __construct(
        private readonly AnnouncementService $announcements,
    ) {}

    /**
     * Paginated parish feed for the authenticated faithful's parish.
     */
    public function index(IndexAnnouncementRequest $request): AnonymousResourceCollection
    {
        /** @var User $user */
        $user = $request->user();

        $parishId = $user->parish_id;

        if ($parishId === null) {
            return AnnouncementResource::collection([]);
        }

        return AnnouncementResource::collection(
            $this->announcements->feedForParish($parishId, $request->perPage()),
        );
    }
}
