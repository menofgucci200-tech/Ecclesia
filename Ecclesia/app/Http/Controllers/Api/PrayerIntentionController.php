<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PrayerIntentionResource;
use App\Models\PrayerIntention;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PrayerIntentionController extends Controller
{
    /** The approved intentions of the faithful's parish. */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if ($user->parish_id === null) {
            return response()->json(['intentions' => [], 'needs_parish' => true]);
        }

        $intentions = PrayerIntention::query()
            ->where('parish_id', $user->parish_id)
            ->where('is_approved', true)
            ->latest()
            ->limit(100)
            ->get();

        $prayedIds = DB::table('prayer_intention_user')
            ->where('user_id', $user->id)
            ->whereIn('prayer_intention_id', $intentions->pluck('id'))
            ->pluck('prayer_intention_id')
            ->all();

        $intentions->each(function (PrayerIntention $i) use ($prayedIds, $user) {
            $i->setAttribute('has_prayed', in_array($i->id, $prayedIds, true));
            $i->setAttribute('is_mine', $i->user_id === $user->id);
        });

        return response()->json(['intentions' => PrayerIntentionResource::collection($intentions)]);
    }

    /** Submit a new intention to the parish wall. */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        if ($user->parish_id === null) {
            return response()->json(['message' => 'Rejoignez d\'abord une paroisse pour partager une intention.'], 422);
        }

        $validated = $request->validate([
            'intention' => ['required', 'string', 'min:3', 'max:500'],
            'is_anonymous' => ['boolean'],
        ]);

        $anonymous = $request->boolean('is_anonymous');

        $intention = PrayerIntention::create([
            'parish_id' => $user->parish_id,
            'user_id' => $user->id,
            'author_name' => $anonymous ? null : $user->first_name,
            'is_anonymous' => $anonymous,
            'intention' => $validated['intention'],
            'prayers_count' => 0,
            'is_approved' => true,
        ]);

        $intention->setAttribute('is_mine', true);
        $intention->setAttribute('has_prayed', false);

        return response()->json(['intention' => new PrayerIntentionResource($intention)], 201);
    }

    /** Record that the faithful prayed for an intention (once). */
    public function pray(Request $request, PrayerIntention $intention): JsonResponse
    {
        $user = $request->user();

        $already = DB::table('prayer_intention_user')
            ->where('prayer_intention_id', $intention->id)
            ->where('user_id', $user->id)
            ->exists();

        if (! $already) {
            $intention->prayedBy()->attach($user->id);
            $intention->increment('prayers_count');
        }

        return response()->json([
            'prayers_count' => $intention->fresh()->prayers_count,
            'has_prayed' => true,
        ]);
    }

    /** Delete one's own intention. */
    public function destroy(Request $request, PrayerIntention $intention): JsonResponse
    {
        abort_unless($intention->user_id === $request->user()->id, 403);

        $intention->delete();

        return response()->json(['deleted' => true]);
    }
}
