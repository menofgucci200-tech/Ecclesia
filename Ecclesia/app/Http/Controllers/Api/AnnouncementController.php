<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Announcement\IndexAnnouncementRequest;
use App\Http\Resources\AnnouncementResource;
use App\Models\Announcement;
use App\Models\AnnouncementLike;
use App\Models\AnnouncementSave;
use App\Models\User;
use App\Services\AnnouncementService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Collection;

class AnnouncementController extends Controller
{
    public function __construct(
        private readonly AnnouncementService $announcements,
    ) {}

    /**
     * Paginated parish feed for the authenticated faithful's parish.
     */
    public function index(IndexAnnouncementRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $parishId = $user->parish_id;

        if ($parishId === null) {
            return response()->json(['data' => []]);
        }

        $paginator = $this->announcements->feedForParish($parishId, $request->perPage());
        $ids = $paginator->pluck('id');
        $savedIds = $this->savedIds($user->id, $ids);
        $likedIds = $this->likedIds($user->id, $ids);

        return response()->json([
            'data' => $paginator->getCollection()
                ->map(fn (Announcement $a) => (new AnnouncementResource(
                    $a,
                    $savedIds->contains($a->id),
                    $likedIds->contains($a->id),
                ))->resolve($request)),
        ]);
    }

    /**
     * Toggles the authenticated faithful's bookmark on an announcement.
     */
    public function toggleSave(Announcement $announcement): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();

        abort_unless($announcement->parish_id === $user->parish_id, 403);

        $save = AnnouncementSave::where('announcement_id', $announcement->id)->where('user_id', $user->id)->first();

        if ($save !== null) {
            $save->delete();
            $isSaved = false;
        } else {
            AnnouncementSave::create(['announcement_id' => $announcement->id, 'user_id' => $user->id]);
            $isSaved = true;
        }

        return response()->json(['is_saved' => $isSaved]);
    }

    /**
     * Toggles the authenticated faithful's like on an announcement.
     */
    public function toggleLike(Announcement $announcement): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();

        abort_unless($announcement->parish_id === $user->parish_id, 403);

        $like = AnnouncementLike::where('announcement_id', $announcement->id)->where('user_id', $user->id)->first();

        if ($like !== null) {
            $like->delete();
            $announcement->decrement('likes_count');
            $isLiked = false;
        } else {
            AnnouncementLike::create(['announcement_id' => $announcement->id, 'user_id' => $user->id]);
            $announcement->increment('likes_count');
            $isLiked = true;
        }

        return response()->json(['is_liked' => $isLiked, 'likes_count' => $announcement->fresh()->likes_count]);
    }

    /**
     * The faithful's saved ("Enregistrées") announcements, most recently saved first.
     */
    public function saved(): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();

        $announcements = Announcement::query()
            ->whereHas('saves', fn ($q) => $q->where('user_id', $user->id))
            ->orderByDesc(
                AnnouncementSave::select('created_at')
                    ->whereColumn('announcement_id', 'announcements.id')
                    ->where('user_id', $user->id)
                    ->limit(1),
            )
            ->get();

        $likedIds = $this->likedIds($user->id, $announcements->pluck('id'));

        return response()->json([
            'data' => $announcements->map(fn (Announcement $a) => (new AnnouncementResource($a, true, $likedIds->contains($a->id)))->resolve(request())),
        ]);
    }

    /**
     * @param  Collection<int, int>  $announcementIds
     * @return Collection<int, int>
     */
    private function savedIds(int $userId, Collection $announcementIds): Collection
    {
        return AnnouncementSave::query()
            ->where('user_id', $userId)
            ->whereIn('announcement_id', $announcementIds)
            ->pluck('announcement_id');
    }

    /**
     * @param  Collection<int, int>  $announcementIds
     * @return Collection<int, int>
     */
    private function likedIds(int $userId, Collection $announcementIds): Collection
    {
        return AnnouncementLike::query()
            ->where('user_id', $userId)
            ->whereIn('announcement_id', $announcementIds)
            ->pluck('announcement_id');
    }
}
