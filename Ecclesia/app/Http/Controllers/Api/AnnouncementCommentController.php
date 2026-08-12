<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AnnouncementCommentResource;
use App\Models\Announcement;
use App\Models\AnnouncementComment;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnnouncementCommentController extends Controller
{
    /**
     * Comments on an announcement, oldest first (conversation order).
     */
    public function index(Announcement $announcement): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();
        abort_unless($announcement->parish_id === $user->parish_id, 403);

        $comments = $announcement->comments()->with('user')->oldest()->get();

        return response()->json(['data' => AnnouncementCommentResource::collection($comments)]);
    }

    public function store(Request $request, Announcement $announcement): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($announcement->parish_id === $user->parish_id, 403);

        $validated = $request->validate([
            'body' => ['required', 'string', 'max:1000'],
        ]);

        $comment = $announcement->comments()->create([
            'user_id' => $user->id,
            'body' => $validated['body'],
        ]);
        $announcement->increment('comments_count');

        return response()->json(['data' => new AnnouncementCommentResource($comment->load('user'))], 201);
    }

    public function destroy(Announcement $announcement, AnnouncementComment $comment): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();
        abort_unless($comment->announcement_id === $announcement->id, 404);
        abort_unless($comment->user_id === $user->id, 403);

        $comment->delete();
        if ($announcement->comments_count > 0) {
            $announcement->decrement('comments_count');
        }

        return response()->json(['deleted' => true]);
    }
}
