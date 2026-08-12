<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Announcement\IndexAnnouncementRequest;
use App\Http\Resources\NotificationResource;
use App\Models\Announcement;
use App\Models\User;
use App\Services\AnnouncementService;
use Illuminate\Http\JsonResponse;

/**
 * The faithful's notification center: today it surfaces the parish feed
 * ("Fil paroissial") against a per-user read watermark, so the bell badge
 * and list are real without a separate fan-out table. Other event types
 * (payment confirmations, intention answers…) can feed the same watermark
 * scheme later without changing this contract.
 */
class NotificationController extends Controller
{
    public function __construct(
        private readonly AnnouncementService $announcements,
    ) {}

    /**
     * Number of parish announcements published since the user last opened
     * the notification center.
     */
    public function unreadCount(): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();

        if ($user->parish_id === null) {
            return response()->json(['count' => 0]);
        }

        $count = Announcement::query()
            ->forParish($user->parish_id)
            ->published()
            ->when(
                $user->notifications_last_seen_at !== null,
                fn ($query) => $query->where('published_at', '>', $user->notifications_last_seen_at),
            )
            ->count();

        return response()->json(['count' => $count]);
    }

    /**
     * Paginated notification list — the parish feed, each item flagged
     * `read` against the user's watermark.
     */
    public function index(IndexAnnouncementRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        if ($user->parish_id === null) {
            return response()->json(['data' => []]);
        }

        $lastSeenAt = $user->notifications_last_seen_at;
        $paginator = $this->announcements->feedForParish($user->parish_id, $request->perPage());

        return response()->json([
            'data' => $paginator->getCollection()
                ->map(fn (Announcement $announcement) => (new NotificationResource($announcement, $lastSeenAt))->resolve($request)),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => $paginator->lastPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
            ],
        ]);
    }

    /**
     * Marks every currently visible notification as read (advances the
     * watermark to now).
     */
    public function markRead(): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();
        $user->forceFill(['notifications_last_seen_at' => now()])->save();

        return response()->json(['notifications_last_seen_at' => $user->notifications_last_seen_at->toIso8601String()]);
    }
}
