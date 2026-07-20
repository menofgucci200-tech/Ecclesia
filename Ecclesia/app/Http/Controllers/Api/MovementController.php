<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Movement;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class MovementController extends Controller
{
    /**
     * All active movements of the faithful's parish, with membership flag.
     */
    public function index(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        if ($user->parish_id === null) {
            return response()->json(['movements' => []]);
        }

        $memberIds = $user->movements()->pluck('movements.id')->all();

        $movements = Movement::query()
            ->where('parish_id', $user->parish_id)
            ->where('is_active', true)
            ->withCount('members')
            ->orderBy('name')
            ->get()
            ->map(fn (Movement $m) => $this->summary($m, in_array($m->id, $memberIds, true)));

        return response()->json(['movements' => $movements]);
    }

    /**
     * The movements the faithful belongs to (for "Mes activités").
     */
    public function mine(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $movements = $user->movements()
            ->where('is_active', true)
            ->withCount('members')
            ->orderBy('name')
            ->get()
            ->map(fn (Movement $m) => $this->summary($m, true));

        return response()->json(['movements' => $movements]);
    }

    /**
     * A movement's detail: posts + documents + membership.
     */
    public function show(Request $request, Movement $movement): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($movement->parish_id === $user->parish_id, 404);

        $isMember = $user->movements()->where('movements.id', $movement->id)->exists();
        $movement->loadCount('members');

        $posts = $movement->posts()
            ->whereNotNull('published_at')
            ->where('published_at', '<=', now())
            ->latest('published_at')
            ->limit(30)
            ->get()
            ->map(fn ($p) => [
                'id' => $p->id,
                'title' => $p->title,
                'body' => $p->body,
                'image_url' => $p->image ? Storage::url($p->image) : null,
                'published_at' => optional($p->published_at)->toIso8601String(),
            ]);

        $documents = $movement->documents()->latest()->get()->map(fn ($d) => [
            'id' => $d->id,
            'title' => $d->title,
            'url' => Storage::url($d->file_path),
            'size' => $d->humanSize(),
        ]);

        return response()->json([
            'movement' => $this->summary($movement, $isMember),
            'posts' => $posts,
            'documents' => $documents,
        ]);
    }

    public function join(Request $request, Movement $movement): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($movement->parish_id === $user->parish_id && $movement->is_active, 404);

        $user->movements()->syncWithoutDetaching([$movement->id => ['joined_at' => now()]]);

        return response()->json(['joined' => true]);
    }

    public function leave(Request $request, Movement $movement): JsonResponse
    {
        $request->user()->movements()->detach($movement->id);

        return response()->json(['joined' => false]);
    }

    /**
     * @return array<string, mixed>
     */
    private function summary(Movement $movement, bool $isMember): array
    {
        return [
            'id' => $movement->id,
            'name' => $movement->name,
            'category' => $movement->category,
            'description' => $movement->description,
            'meeting_info' => $movement->meeting_info,
            'logo_url' => $movement->logo ? Storage::url($movement->logo) : null,
            'members_count' => $movement->members_count ?? $movement->members()->count(),
            'is_member' => $isMember,
        ];
    }
}
